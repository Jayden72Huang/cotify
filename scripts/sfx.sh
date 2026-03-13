#!/bin/bash
# Sound effect player for macOS
# Usage: sfx.sh <effect_name>
# Effects: success, error, notify, start, celebrate, levelup, coin

EFFECT="${1:-notify}"

# ── 读取全局模式配置 ────────────────────────────────────────
VN_CONFIG="$HOME/.voice_notify_config"
VN_MODE="normal"
[ -f "$VN_CONFIG" ] && VN_MODE=$(cat "$VN_CONFIG")

# mute 模式：完全静音
[ "$VN_MODE" = "mute" ] && exit 0

# quiet 模式：只允许 celebrate 和 error 音效
if [ "$VN_MODE" = "quiet" ]; then
  case "$EFFECT" in
    celebrate|error) ;;  # 允许
    *) exit 0 ;;         # 其余静音
  esac
fi

# macOS system sounds path
SYS="/System/Library/Sounds"

play_sound() {
  if command -v afplay &> /dev/null; then
    afplay "$1" &
  fi
}

case "$EFFECT" in
  success)
    play_sound "$SYS/Glass.aiff"
    ;;
  error)
    play_sound "$SYS/Sosumi.aiff"
    ;;
  notify)
    play_sound "$SYS/Tink.aiff"
    ;;
  start)
    play_sound "$SYS/Blow.aiff"
    ;;
  celebrate)
    # Play a quick ascending sequence
    play_sound "$SYS/Hero.aiff"
    ;;
  levelup)
    play_sound "$SYS/Purr.aiff"
    ;;
  coin)
    play_sound "$SYS/Pop.aiff"
    ;;
  warning)
    play_sound "$SYS/Basso.aiff"
    ;;
  checkin)
    play_sound "$SYS/Morse.aiff"
    ;;
  *)
    play_sound "$SYS/Tink.aiff"
    ;;
esac
