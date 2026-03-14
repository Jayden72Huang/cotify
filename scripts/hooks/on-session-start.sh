#!/bin/bash
# Hook: SessionStart — 会话启动时触发
SKILL_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
VN_LANG="zh"
[ -f "$HOME/.voice_notify_lang" ] && VN_LANG=$(cat "$HOME/.voice_notify_lang")

bash "$SKILL_DIR/scripts/sfx.sh" start &
if [ "$VN_LANG" = "en" ]; then
  bash "$SKILL_DIR/scripts/voice.sh" "Session started, ready to go" --preset=normal --time-aware &
else
  bash "$SKILL_DIR/scripts/voice.sh" "会话已启动，准备就绪" --preset=normal --time-aware &
fi
