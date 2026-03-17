#!/bin/bash
# =============================================================
# voice-notify setup check — macOS only
# Usage: bash setup.sh [--auto]
#   --auto: non-interactive, just check and print status
# =============================================================

AUTO=false
[[ "$1" == "--auto" ]] && AUTO=true

BOLD="\033[1m"
GREEN="\033[0;32m"
RED="\033[0;31m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
RESET="\033[0m"

ok()   { echo -e "${GREEN}✅ $*${RESET}"; }
fail() { echo -e "${RED}❌ $*${RESET}"; }
warn() { echo -e "${YELLOW}⚠️  $*${RESET}"; }
info() { echo -e "${CYAN}ℹ️  $*${RESET}"; }
hr()   { echo -e "${BOLD}──────────────────────────────────────${RESET}"; }

hr
echo -e "${BOLD}  Voice Notify — macOS 环境检测${RESET}"
hr

ERRORS=0

# ── 1. 平台检测 ────────────────────────────────────────────
if [[ "$(uname)" != "Darwin" ]]; then
  fail "此 skill 仅支持 macOS，当前系统：$(uname)"
  echo ""
  echo "Linux 用户请安装 espeak: sudo apt install espeak"
  exit 1
fi
ok "macOS $(sw_vers -productVersion)"

# ── 2. say 命令 ────────────────────────────────────────────
if ! command -v say &>/dev/null; then
  fail "'say' 命令不存在（macOS 上不应发生此情况）"
  ((ERRORS++))
else
  ok "say 命令可用"
fi

# ── 3. afplay（音效）──────────────────────────────────────
if ! command -v afplay &>/dev/null; then
  warn "afplay 不可用，音效功能将被禁用"
else
  ok "afplay 可用（音效功能正常）"
fi

echo ""
hr
echo -e "${BOLD}  语音音色检测${RESET}"
hr

# 获取已安装语音列表
VOICE_LIST=$(bash -c "say -v '?' 2>/dev/null")

check_voice() {
  local name="$1"
  if echo "$VOICE_LIST" | grep -qi "^${name}[[:space:]]"; then
    ok "已安装: $name"
    return 0
  else
    fail "未安装: $name"
    return 1
  fi
}

# 检查推荐语音
echo -e "\n${BOLD}推荐语音（中文）：${RESET}"
check_voice "Lili (Premium)"   || ((ERRORS++))
check_voice "Yue (Premium)"    || true   # 可选
check_voice "Meijia (Enhanced)"|| true   # 可选

echo -e "\n${BOLD}说明：${RESET}"
info "macOS 的 'say' 命令无法直接调用 Siri 语音引擎（两套独立系统）"
info "最接近 Siri 中文音色的替代方案是 Lili (Premium) ——温和自然的普通话女声"

# ── 4. 缺失语音的安装引导 ──────────────────────────────────
if ! echo "$VOICE_LIST" | grep -qi "^Lili (Premium)"; then
  echo ""
  hr
  echo -e "${BOLD}  需要下载语音音色${RESET}"
  hr
  echo ""
  echo -e "${BOLD}请按以下步骤下载 Lili (Premium)：${RESET}"
  echo ""
  echo "  1. 打开「系统设置」→「辅助功能」→「朗读内容」"
  echo "     （macOS Ventura/Sonoma 路径）"
  echo ""
  echo "  2. 点击「系统语音」旁边的下拉菜单 → 选「管理语音…」"
  echo ""
  echo "  3. 在列表中找到「中文（中国大陆）」→ 展开"
  echo "     找到「莉莉 (Premium)」→ 点击下载按钮 ⬇"
  echo ""
  echo "  4. 下载完成后重新运行此脚本验证："
  echo "     bash $(realpath "$0")"
  echo ""
  echo "  💡 也可选择下载「月 (Premium)」作为备用音色"
  echo ""

  if [[ "$AUTO" == false ]]; then
    read -rp "是否立即打开「系统设置 → 辅助功能」？[y/N] " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
      open "x-apple.systempreferences:com.apple.preference.universalaccess"
      echo ""
      info "已打开系统设置，请导航到「朗读内容」→「管理语音…」"
    fi
  fi
fi

# ── 5. 快速测试 ───────────────────────────────────────────
echo ""
hr
echo -e "${BOLD}  快速测试${RESET}"
hr

if echo "$VOICE_LIST" | grep -qi "^Lili (Premium)"; then
  BEST_VOICE="Lili (Premium)"
elif echo "$VOICE_LIST" | grep -qi "^Yue (Premium)"; then
  BEST_VOICE="Yue (Premium)"
elif echo "$VOICE_LIST" | grep -qi "^Lili"; then
  BEST_VOICE="Lili (Enhanced)"
else
  BEST_VOICE="Tingting"
fi

if [[ "$AUTO" == false ]]; then
  read -rp "是否播放测试语音？[y/N] " test_ans
  if [[ "$test_ans" =~ ^[Yy]$ ]]; then
    echo ""
    info "正在使用「$BEST_VOICE」播放测试语音..."
    say -v "$BEST_VOICE" -r 200 "你好，语音提醒配置成功，准备就绪！"
    ok "测试完成"
    echo ""
    afplay "/System/Library/Sounds/Glass.aiff" 2>/dev/null &
    info "音效测试完成"
  fi
fi

# ── 6. 安装 vn / vm 快捷命令 ─────────────────────────────
echo ""
hr
echo -e "${BOLD}  快捷命令 vn / vm${RESET}"
hr

SCRIPTS_DIR="$(cd "$(dirname "$0")" && pwd)"
VN_ALIAS="alias vn='bash \"$SCRIPTS_DIR/vn.sh\"'"
VM_ALIAS="alias vm='bash \"$SCRIPTS_DIR/vm.sh\"'"

install_alias() {
  local rc="$1"
  local alias_line="$2"
  local script_name="$3"
  if [ -f "$rc" ] && grep -qF "$script_name" "$rc"; then
    ok "$script_name 已存在于 $rc"
    return 0
  fi
  echo "" >> "$rc"
  echo "# voice-notify: $script_name" >> "$rc"
  echo "$alias_line" >> "$rc"
  ok "$script_name 已添加到 $rc"
  return 0
}

# 检测 shell 并安装
RC_FILE=""
if [[ "$SHELL" == *zsh* ]] || [ -f "$HOME/.zshrc" ]; then
  RC_FILE="$HOME/.zshrc"
elif [[ "$SHELL" == *bash* ]] || [ -f "$HOME/.bashrc" ]; then
  RC_FILE="$HOME/.bashrc"
fi

if [ -n "$RC_FILE" ]; then
  install_alias "$RC_FILE" "$VN_ALIAS" "vn.sh"
  install_alias "$RC_FILE" "$VM_ALIAS" "vm.sh"
else
  warn "未识别 shell，请手动添加到 shell 配置文件："
  echo "  $VN_ALIAS"
  echo "  $VM_ALIAS"
fi

echo ""
info "安装后新开终端即可使用："
info "  vn quiet / vn normal / vn mute / vn hype  （模式切换）"
info "  vm mute / vm unmute                        （快速静音开关）"

# ── 7. 汇总 ───────────────────────────────────────────────
echo ""
hr
if [[ $ERRORS -eq 0 ]]; then
  echo -e "${GREEN}${BOLD}  ✅ 环境检测通过，语音提醒功能已就绪！${RESET}"
  echo ""
  info "默认使用音色：$BEST_VOICE"
  info "模式切换：vn quiet / vn normal / vn mute / vn hype"
else
  echo -e "${YELLOW}${BOLD}  ⚠️  发现 $ERRORS 个问题，请按上方指引完成配置${RESET}"
fi
hr
echo ""
