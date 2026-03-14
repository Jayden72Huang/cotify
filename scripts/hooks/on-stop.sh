#!/bin/bash
# Hook: Stop — Claude 完成一轮回复时触发
# Claude 在任务结束前将摘要写入 /tmp/voice_notify_summary，本脚本读取播报
SKILL_DIR="$(cd "$(dirname "$0")/../.." && pwd)"
VN_LANG="zh"
[ -f "$HOME/.voice_notify_lang" ] && VN_LANG=$(cat "$HOME/.voice_notify_lang")

SUMMARY_FILE="/tmp/voice_notify_summary"
ERROR_COUNT_FILE="/tmp/voice_notify_error_count"

# 读取任务摘要
SUMMARY=""
if [ -f "$SUMMARY_FILE" ]; then
  SUMMARY=$(cat "$SUMMARY_FILE" 2>/dev/null)
  rm -f "$SUMMARY_FILE"
fi

# 读取错误计数
ERROR_COUNT=0
if [ -f "$ERROR_COUNT_FILE" ]; then
  ERROR_COUNT=$(cat "$ERROR_COUNT_FILE" 2>/dev/null)
  rm -f "$ERROR_COUNT_FILE"
fi

# 组合播报消息
if [ -n "$SUMMARY" ]; then
  # 有摘要：播报摘要 + 错误信息（如有）
  MSG="$SUMMARY"
  if [ "$ERROR_COUNT" -gt 0 ] 2>/dev/null; then
    if [ "$VN_LANG" = "en" ]; then
      MSG="$MSG. $ERROR_COUNT errors occurred and resolved"
    else
      MSG="$MSG。过程中出现${ERROR_COUNT}个错误，已解决"
    fi
  fi
else
  # 无摘要：简单播报完成
  if [ "$VN_LANG" = "en" ]; then
    MSG="Task complete"
  else
    MSG="任务完成"
  fi
  if [ "$ERROR_COUNT" -gt 0 ] 2>/dev/null; then
    if [ "$VN_LANG" = "en" ]; then
      MSG="$MSG. $ERROR_COUNT errors occurred and resolved"
    else
      MSG="$MSG，过程中出现${ERROR_COUNT}个错误，已解决"
    fi
  fi
fi

bash "$SKILL_DIR/scripts/sfx.sh" success &
bash "$SKILL_DIR/scripts/voice.sh" "$MSG" --preset=celebrate --time-aware --debounce=5 &
