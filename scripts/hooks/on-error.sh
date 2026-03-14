#!/bin/bash
# Hook: PostToolUseFailure — 工具执行失败时触发
SKILL_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
bash "$SKILL_DIR/scripts/sfx.sh" error &
bash "$SKILL_DIR/scripts/voice.sh" "出现错误，请检查" --preset=comfort --debounce=10 &
