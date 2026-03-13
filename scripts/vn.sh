#!/bin/bash
# =============================================================
# vn — voice-notify 模式快捷切换
#
# Usage:
#   vn quiet    安静模式（只播完成+严重错误）
#   vn normal   正常模式（默认 milestone 行为）
#   vn mute     完全静音
#   vn hype     全开（每步都播，语气词拉满）
#   vn status   查看当前模式
# =============================================================

CONFIG="$HOME/.voice_notify_config"
BOLD="\033[1m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
CYAN="\033[0;36m"
RED="\033[0;31m"
RESET="\033[0m"

# 读当前模式
current_mode() {
  [ -f "$CONFIG" ] && cat "$CONFIG" || echo "normal"
}

# 写模式
set_mode() {
  echo "$1" > "$CONFIG"
}

# 带音效的模式切换提示
announce() {
  local mode="$1"
  local sfx_dir="$(cd "$(dirname "$0")" && pwd)"
  case "$mode" in
    mute)
      echo -e "${RED}🔇 已切换到 mute（完全静音）${RESET}"
      ;;
    quiet)
      bash "$sfx_dir/sfx.sh" notify 2>/dev/null &
      bash "$sfx_dir/voice.sh" "已切换到安静模式" --preset=normal --vibe=chill 2>/dev/null &
      echo -e "${YELLOW}🔈 已切换到 quiet（只播完成+错误）${RESET}"
      ;;
    normal)
      bash "$sfx_dir/sfx.sh" success 2>/dev/null &
      bash "$sfx_dir/voice.sh" "已切换到正常模式" --preset=normal 2>/dev/null &
      echo -e "${GREEN}🔊 已切换到 normal（默认）${RESET}"
      ;;
    hype)
      bash "$sfx_dir/sfx.sh" celebrate 2>/dev/null &
      bash "$sfx_dir/voice.sh" "全开模式启动，冲冲冲！" --preset=celebrate --vibe=hype 2>/dev/null &
      echo -e "${CYAN}📢 已切换到 hype（全力输出）${RESET}"
      ;;
  esac
}

case "${1:-status}" in
  quiet|q)
    set_mode "quiet"
    announce "quiet"
    ;;
  normal|n)
    set_mode "normal"
    announce "normal"
    ;;
  mute|m)
    set_mode "mute"
    announce "mute"
    ;;
  hype|h)
    set_mode "hype"
    announce "hype"
    ;;
  status|s)
    MODE=$(current_mode)
    echo ""
    echo -e "${BOLD}  🔔 voice-notify 当前模式：${CYAN}${MODE}${RESET}"
    echo ""
    echo -e "  ${BOLD}可用命令：${RESET}"
    echo -e "    vn quiet  (q)   🔈 只播完成+错误"
    echo -e "    vn normal (n)   🔊 默认行为"
    echo -e "    vn mute   (m)   🔇 完全静音"
    echo -e "    vn hype   (h)   📢 全力输出"
    echo -e "    vn status (s)   查看当前模式"
    echo ""
    ;;
  *)
    echo "Unknown mode: $1"
    echo "Usage: vn [quiet|normal|mute|hype|status]"
    exit 1
    ;;
esac
