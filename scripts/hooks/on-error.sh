#!/bin/bash
# Hook: PostToolUseFailure — 工具执行失败时触发
SKILL_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
VN_LANG="zh"
[ -f "$HOME/.voice_notify_lang" ] && VN_LANG=$(cat "$HOME/.voice_notify_lang")

bash "$SKILL_DIR/scripts/sfx.sh" error &
if [ "$VN_LANG" = "en" ]; then
  bash "$SKILL_DIR/scripts/voice.sh" "An error occurred, please check" --preset=comfort --debounce=10 &
else
  bash "$SKILL_DIR/scripts/voice.sh" "出现错误，请检查" --preset=comfort --debounce=10 &
fi
