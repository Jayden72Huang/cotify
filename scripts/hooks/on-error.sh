#!/bin/bash
# Hook: PostToolUseFailure — 工具执行失败时触发
# 静默：agent 运行中会自行解决，不打扰用户
# 仅记录错误计数，任务结束时由 on-stop.sh 汇报

ERROR_COUNT_FILE="/tmp/voice_notify_error_count"
COUNT=0
[ -f "$ERROR_COUNT_FILE" ] && COUNT=$(cat "$ERROR_COUNT_FILE" 2>/dev/null)
echo $(( COUNT + 1 )) > "$ERROR_COUNT_FILE"
