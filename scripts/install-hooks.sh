#!/bin/bash
# =============================================================
# voice-notify — 自动安装 Claude Code Hooks
#
# Usage: bash install-hooks.sh [--uninstall]
#   --uninstall: 移除 voice-notify 的 hooks
# =============================================================

SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
HOOKS_DIR="$SKILL_DIR/scripts/hooks"
SETTINGS="$HOME/.claude/settings.json"

BOLD="\033[1m"
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
RESET="\033[0m"

ok()   { echo -e "${GREEN}✅ $*${RESET}"; }
fail() { echo -e "${RED}❌ $*${RESET}"; }
info() { echo -e "${CYAN}ℹ️  $*${RESET}"; }
hr()   { echo -e "${BOLD}──────────────────────────────────────${RESET}"; }

# ── 检查 jq ────────────────────────────────────────────────
if ! command -v jq &>/dev/null; then
  fail "需要 jq 来修改 settings.json"
  echo "  安装: brew install jq"
  exit 1
fi

# ── 检查 settings.json 存在 ────────────────────────────────
if [ ! -f "$SETTINGS" ]; then
  fail "未找到 $SETTINGS"
  echo "  请先确认 Claude Code 已初始化"
  exit 1
fi

# ── 卸载模式 ───────────────────────────────────────────────
if [[ "$1" == "--uninstall" ]]; then
  hr
  echo -e "${BOLD}  Voice Notify — 移除 Hooks${RESET}"
  hr

  # 移除包含 voice-notify 路径的 hooks
  TEMP=$(mktemp)
  jq --arg skill_dir "$SKILL_DIR" '
    .hooks |= (if . then
      to_entries | map(
        .value |= map(
          .hooks |= map(select(.command | test($skill_dir) | not))
          | select(.hooks | length > 0)
        )
        | select(.value | length > 0)
      ) | from_entries
    else . end)
  ' "$SETTINGS" > "$TEMP" && mv "$TEMP" "$SETTINGS"

  ok "已移除 voice-notify 的 hooks"
  info "其他 hooks 保持不变"
  exit 0
fi

# ── 安装模式 ───────────────────────────────────────────────
hr
echo -e "${BOLD}  Voice Notify — 安装 Hooks${RESET}"
hr

# 检查是否已安装
if grep -q "voice-notify" "$SETTINGS" 2>/dev/null; then
  info "检测到已安装的 voice-notify hooks，将更新为最新版本"
  # 先卸载旧的
  bash "$0" --uninstall 2>/dev/null
fi

# 备份
cp "$SETTINGS" "${SETTINGS}.bak"
info "已备份 settings.json → settings.json.bak"

# ── 定义要注入的 hooks ─────────────────────────────────────
# 使用 jq 安全合并，不覆盖用户已有的 hooks
TEMP=$(mktemp)

jq --arg hooks_dir "$HOOKS_DIR" '
  # 确保 .hooks 存在
  .hooks //= {} |

  # SessionStart
  .hooks.SessionStart = ((.hooks.SessionStart // []) + [{
    "matcher": "startup",
    "hooks": [{
      "type": "command",
      "command": ("bash " + $hooks_dir + "/on-session-start.sh")
    }]
  }]) |

  # Stop（替换原有的简单 afplay，保留其他 Stop hooks）
  .hooks.Stop = (
    [(.hooks.Stop // [])[] | select(.hooks | all(.command | test("voice-notify") | not))] +
    [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": ("bash " + $hooks_dir + "/on-stop.sh")
      }]
    }]
  ) |

  # Notification（替换原有的简单 afplay）
  .hooks.Notification = (
    [(.hooks.Notification // [])[] | select(.hooks | all(.command | test("voice-notify") | not))] +
    [{
      "matcher": "",
      "hooks": [{
        "type": "command",
        "command": ("bash " + $hooks_dir + "/on-notification.sh")
      }]
    }]
  ) |

  # PostToolUseFailure（新增）
  .hooks.PostToolUseFailure = ((.hooks.PostToolUseFailure // []) + [{
    "matcher": "",
    "hooks": [{
      "type": "command",
      "command": ("bash " + $hooks_dir + "/on-error.sh")
    }]
  }])
' "$SETTINGS" > "$TEMP"

if [ $? -eq 0 ] && [ -s "$TEMP" ]; then
  mv "$TEMP" "$SETTINGS"
  echo ""
  ok "Hooks 安装成功！"
  echo ""
  echo -e "  ${BOLD}已注册的事件：${RESET}"
  echo -e "    ${GREEN}▸${RESET} SessionStart  — 会话启动时播报"
  echo -e "    ${GREEN}▸${RESET} Stop          — 任务完成时庆祝"
  echo -e "    ${GREEN}▸${RESET} Notification  — 需要关注时提醒"
  echo -e "    ${GREEN}▸${RESET} PostToolUseFailure — 出错时安抚"
  echo ""
  echo -e "  ${BOLD}控制音量：${RESET}"
  echo -e "    vn mute     完全静音"
  echo -e "    vn quiet    只播完成+错误"
  echo -e "    vn normal   默认行为"
  echo -e "    vn hype     全力输出"
  echo ""
  echo -e "  ${BOLD}卸载：${RESET}"
  echo -e "    bash $SKILL_DIR/scripts/install-hooks.sh --uninstall"
  echo ""
  hr
  echo -e "${GREEN}${BOLD}  ✅ 重启 Claude Code 后 hooks 生效！${RESET}"
  hr
else
  fail "安装失败，已恢复备份"
  [ -f "${SETTINGS}.bak" ] && mv "${SETTINGS}.bak" "$SETTINGS"
  rm -f "$TEMP"
  exit 1
fi
