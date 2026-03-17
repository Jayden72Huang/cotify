#!/bin/bash
# =============================================================
# vm — Voice Mute 快速静音开关
#
# voice-notify skill 的快捷静音/恢复命令
#
# Usage:
#   vm mute      静音（voice-notify 的语音+音效）
#   vm unmute    恢复之前的模式
#   vm status    查看当前状态
#   vm          （无参数）等同于 vm status
#
# 与 vn 的区别：
#   vn = 细粒度模式切换（mute/quiet/normal/hype）
#   vm = 快速一键 mute/unmute，unmute 时自动恢复之前的模式
# =============================================================

CONFIG="$HOME/.voice_notify_config"
PREV_MODE_FILE="$HOME/.voice_notify_prev_mode"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

BOLD="\033[1m"
GREEN="\033[0;32m"
RED="\033[0;31m"
CYAN="\033[0;36m"
RESET="\033[0m"

current_mode() {
  [ -f "$CONFIG" ] && cat "$CONFIG" || echo "normal"
}

case "${1:-status}" in
  mute|m)
    CUR=$(current_mode)
    if [ "$CUR" != "mute" ]; then
      echo "$CUR" > "$PREV_MODE_FILE"
    fi
    echo "mute" > "$CONFIG"
    echo -e "${RED}🔇 voice-notify 已静音${RESET}"
    echo -e "   恢复：${BOLD}vm unmute${RESET}"
    ;;

  unmute|u)
    if [ -f "$PREV_MODE_FILE" ]; then
      PREV=$(cat "$PREV_MODE_FILE")
      echo "$PREV" > "$CONFIG"
      rm -f "$PREV_MODE_FILE"
      echo -e "${GREEN}🔊 voice-notify 已恢复 — 模式：${CYAN}${PREV}${RESET}"
    else
      echo "normal" > "$CONFIG"
      echo -e "${GREEN}🔊 voice-notify 已恢复 — 模式：${CYAN}normal${RESET}"
    fi
    bash "$SCRIPT_DIR/sfx.sh" notify 2>/dev/null &
    ;;

  status|s)
    MODE=$(current_mode)
    echo ""
    if [ "$MODE" = "mute" ]; then
      echo -e "  ${RED}🔇 voice-notify：静音中${RESET}"
    else
      echo -e "  ${GREEN}🔊 voice-notify：${CYAN}${MODE}${RESET}"
    fi
    echo ""
    echo -e "  ${BOLD}命令：${RESET}"
    echo -e "    vm mute     🔇 静音"
    echo -e "    vm unmute   🔊 恢复"
    echo -e "    vm status   查看状态"
    echo ""
    ;;

  *)
    echo "Usage: vm [mute|unmute|status]"
    exit 1
    ;;
esac
