#!/bin/bash
# Hook: SessionStart — 会话启动时触发
SKILL_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
VN_LANG="zh"
[ -f "$HOME/.voice_notify_lang" ] && VN_LANG=$(cat "$HOME/.voice_notify_lang")

# 清理上一次会话的时段感知状态，确保新会话重新计时
rm -f /tmp/voice_notify_session_start
rm -f /tmp/voice_notify_period_seen
rm -f /tmp/voice_notify_care_last

bash "$SKILL_DIR/scripts/sfx.sh" start &
if [ "$VN_LANG" = "en" ]; then
  bash "$SKILL_DIR/scripts/voice.sh" "Session started, ready to go" --preset=normal --time-aware &
else
  bash "$SKILL_DIR/scripts/voice.sh" "会话已启动，准备就绪" --preset=normal --time-aware &
fi
