#!/bin/bash
# Hook: Notification — 需要用户关注时触发
SKILL_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
bash "$SKILL_DIR/scripts/sfx.sh" warning &
bash "$SKILL_DIR/scripts/voice.sh" "需要您的关注" --preset=alert --no-filler --debounce=5 &
