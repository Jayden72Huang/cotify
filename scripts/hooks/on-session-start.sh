#!/bin/bash
# Hook: SessionStart — 会话启动时触发
SKILL_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
bash "$SKILL_DIR/scripts/sfx.sh" start &
bash "$SKILL_DIR/scripts/voice.sh" "会话已启动，准备就绪" --preset=normal --time-aware &
