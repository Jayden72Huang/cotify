#!/bin/bash
# Hook: Stop — Claude 完成一轮回复时触发
SKILL_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
bash "$SKILL_DIR/scripts/sfx.sh" success &
bash "$SKILL_DIR/scripts/voice.sh" "任务完成" --preset=celebrate --time-aware --debounce=5 &
