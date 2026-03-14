#!/bin/bash
# Hook: Notification — 需要用户确认时触发（如工具使用授权）
# agent 进程已中断，等待用户操作！
SKILL_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
VN_LANG="zh"
[ -f "$HOME/.voice_notify_lang" ] && VN_LANG=$(cat "$HOME/.voice_notify_lang")

# 播两次音效，确保用户注意到
bash "$SKILL_DIR/scripts/sfx.sh" warning &
sleep 0.5
bash "$SKILL_DIR/scripts/sfx.sh" warning &

if [ "$VN_LANG" = "en" ]; then
  bash "$SKILL_DIR/scripts/voice.sh" "Hey! Tool permission needed, please approve" --preset=alert --no-filler &
else
  bash "$SKILL_DIR/scripts/voice.sh" "老板，有工具需要授权，请过来确认" --preset=alert --no-filler &
fi
