#!/bin/bash
# Hook: Stop — Claude 完成一轮回复时触发
SKILL_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
VN_LANG="zh"
[ -f "$HOME/.voice_notify_lang" ] && VN_LANG=$(cat "$HOME/.voice_notify_lang")

bash "$SKILL_DIR/scripts/sfx.sh" success &
if [ "$VN_LANG" = "en" ]; then
  bash "$SKILL_DIR/scripts/voice.sh" "Task complete" --preset=celebrate --time-aware --debounce=5 &
else
  bash "$SKILL_DIR/scripts/voice.sh" "任务完成" --preset=celebrate --time-aware --debounce=5 &
fi
