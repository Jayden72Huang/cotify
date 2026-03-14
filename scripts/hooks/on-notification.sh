#!/bin/bash
# Hook: Notification — 需要用户关注时触发
SKILL_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
VN_LANG="zh"
[ -f "$HOME/.voice_notify_lang" ] && VN_LANG=$(cat "$HOME/.voice_notify_lang")

bash "$SKILL_DIR/scripts/sfx.sh" warning &
if [ "$VN_LANG" = "en" ]; then
  bash "$SKILL_DIR/scripts/voice.sh" "Needs your attention" --preset=alert --no-filler --debounce=5 &
else
  bash "$SKILL_DIR/scripts/voice.sh" "需要您的关注" --preset=alert --no-filler --debounce=5 &
fi
