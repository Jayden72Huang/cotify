#!/bin/bash
# =============================================================
# voice-notify — TTS script (macOS only)
#
# Usage:
#   voice.sh "<message>" [voice] [rate] [flags...]
#
# Flags:
#   --preset=<name>     情感预设: celebrate|comfort|encourage|alert|normal
#   --vibe=<level>      情绪强度: chill|normal|hype
#   --time-aware        根据当前时段在消息前加上下文
#   --queue             等待上一条语音播完再说（防打断）
#   --debounce=<sec>    防抖：同类事件X秒内只播一次
#   --no-filler         禁用语气词注入
# =============================================================

# ── 参数解析 ─────────────────────────────────────────────────
MESSAGE="${1:-}"
VOICE_ARG=""
RATE_ARG=""
PRESET="normal"
VIBE="normal"
TIME_AWARE=false
QUEUE_MODE=false
DEBOUNCE_SECS=0
NO_FILLER=false

for arg in "${@:2}"; do
  case "$arg" in
    --preset=*)    PRESET="${arg#--preset=}" ;;
    --vibe=*)      VIBE="${arg#--vibe=}" ;;
    --time-aware)  TIME_AWARE=true ;;
    --queue)       QUEUE_MODE=true ;;
    --debounce=*)  DEBOUNCE_SECS="${arg#--debounce=}" ;;
    --no-filler)   NO_FILLER=true ;;
    *)
      if [[ "$arg" =~ ^[0-9]+$ ]]; then
        RATE_ARG="$arg"
      elif [[ ! "$arg" == --* ]] && [[ -n "$arg" ]]; then
        VOICE_ARG="$arg"
      fi
      ;;
  esac
done

if [ -z "$MESSAGE" ]; then
  echo "Usage: voice.sh <message> [voice] [rate] [--preset=celebrate|comfort|encourage|alert|normal] [--vibe=chill|normal|hype]"
  exit 1
fi

# ── 仅支持 macOS ──────────────────────────────────────────────
if [[ "$(uname)" != "Darwin" ]] || ! command -v say &>/dev/null; then
  echo "[Voice] $MESSAGE"
  exit 0
fi

# ── 读取全局模式配置（vn.sh 写入）────────────────────────────
VN_CONFIG="$HOME/.voice_notify_config"
VN_MODE="normal"
[ -f "$VN_CONFIG" ] && VN_MODE=$(cat "$VN_CONFIG")

case "$VN_MODE" in
  mute)
    exit 0  # 完全静音，直接退出
    ;;
  quiet)
    # 安静模式：只允许 celebrate（完成）和 alert（严重错误）
    if [[ "$PRESET" != "celebrate" && "$PRESET" != "alert" ]]; then
      exit 0
    fi
    VIBE="chill"       # 强制无语气词
    NO_FILLER=true
    ;;
  hype)
    VIBE="hype"        # 强制全开
    ;;
  # normal: 不干预，使用调用方传入的参数
esac

# ── 防抖（同类事件短时间内只播一次）──────────────────────────
if [ "$DEBOUNCE_SECS" -gt 0 ] 2>/dev/null; then
  DEBOUNCE_DIR="/tmp/voice_notify_debounce"
  mkdir -p "$DEBOUNCE_DIR"
  EVENT_KEY=$(printf '%s_%s' "$PRESET" "${MESSAGE:0:20}" | tr -cs 'a-zA-Z0-9_' '_')
  DEBOUNCE_FILE="$DEBOUNCE_DIR/$EVENT_KEY"
  NOW=$(date +%s)
  if [ -f "$DEBOUNCE_FILE" ]; then
    LAST=$(cat "$DEBOUNCE_FILE" 2>/dev/null)
    if [ -n "$LAST" ] && [ $(( NOW - LAST )) -lt "$DEBOUNCE_SECS" ]; then
      exit 0
    fi
  fi
  echo "$NOW" > "$DEBOUNCE_FILE"
fi

# ── 情感预设：rate + 语气词池 ─────────────────────────────────
apply_preset() {
  local p="$1"
  case "$p" in
    celebrate)
      PRESET_RATE=200
      PRE_POOL=("哇！" "太棒了！" "" "冲！" "")
      POST_POOL=("漂亮！" "干得好！" "" "冲！" "")
      ;;
    comfort)
      PRESET_RATE=165
      PRE_POOL=("嗯..." "没事的，" "慢慢来，" "" "")
      POST_POOL=("" "会好的。" "" "别担心。" "")
      ;;
    encourage)
      PRESET_RATE=210
      PRE_POOL=("" "来，" "" "好，" "")
      POST_POOL=("加油！" "冲冲冲！" "继续！" "稳住！" "")
      ;;
    alert)
      PRESET_RATE=210
      PRE_POOL=("注意，" "警告！" "注意！" "")
      POST_POOL=("" "" "" "")
      ;;
    *)  # normal
      PRESET_RATE=200
      PRE_POOL=("" "" "" "好，" "")
      POST_POOL=("" "" "" "" "")
      ;;
  esac
}

apply_preset "$PRESET"

# ── 最终语速（显式 rate 参数优先于预设）──────────────────────
if [[ "$RATE_ARG" =~ ^[0-9]+$ ]]; then
  FINAL_RATE="$RATE_ARG"
else
  FINAL_RATE="$PRESET_RATE"
fi

# ── 语气词注入 ────────────────────────────────────────────────
# vibe=chill  → 强制不加语气词
# vibe=normal → 约 60% 概率（PRE_POOL/POST_POOL 含空串实现）
# vibe=hype   → 必定加前缀和后缀（从非空词里选）

pick_random() {
  local count=$#
  [ "$count" -eq 0 ] && echo "" && return
  local idx=$(( RANDOM % count + 1 ))
  echo "${!idx}"
}

pick_random_nonempty() {
  # 只从非空词中选，vibe=hype 使用
  local nonempty=()
  for w in "$@"; do
    [ -n "$w" ] && nonempty+=("$w")
  done
  [ ${#nonempty[@]} -eq 0 ] && echo "" && return
  local idx=$(( RANDOM % ${#nonempty[@]} ))
  echo "${nonempty[$idx]}"
}

if [ "$NO_FILLER" = true ] || [ "$VIBE" = "chill" ]; then
  PRE_FILLER=""
  POST_FILLER=""
elif [ "$VIBE" = "hype" ]; then
  PRE_FILLER=$(pick_random_nonempty "${PRE_POOL[@]}")
  POST_FILLER=$(pick_random_nonempty "${POST_POOL[@]}")
else
  # normal：含空串，自然随机
  PRE_FILLER=$(pick_random "${PRE_POOL[@]}")
  POST_FILLER=$(pick_random "${POST_POOL[@]}")
fi

# ── 时段感知前缀 ──────────────────────────────────────────────
TIME_PREFIX=""
if [ "$TIME_AWARE" = true ]; then
  HOUR=$(date +%H | sed 's/^0//')
  if   [ "$HOUR" -ge 5  ] && [ "$HOUR" -lt 10 ]; then
    TIME_PREFIX="早啊，"
  elif [ "$HOUR" -ge 22 ] || [ "$HOUR" -lt 5  ]; then
    TIME_PREFIX="这么晚啊，"
  elif [ "$HOUR" -ge 18 ] && [ "$HOUR" -lt 22 ]; then
    TIME_PREFIX="傍晚了，"
  fi
fi

# ── 组合最终消息 ──────────────────────────────────────────────
FINAL_MESSAGE="${TIME_PREFIX}${PRE_FILLER}${MESSAGE}${POST_FILLER}"

# ── 语音列表（带1小时缓存，避免每次查询）────────────────────
VOICE_CACHE="/tmp/voice_notify_voices.cache"
if [ ! -f "$VOICE_CACHE" ] || [ $(( $(date +%s) - $(stat -f %m "$VOICE_CACHE" 2>/dev/null || echo 0) )) -gt 3600 ]; then
  bash -c "say -v '?' 2>/dev/null" > "$VOICE_CACHE"
fi
VOICE_LIST=$(cat "$VOICE_CACHE")

voice_available() {
  echo "$VOICE_LIST" | grep -qi "^${1}[[:space:]]"
}

pick_best_voice() {
  local preferred=("Lili (Premium)" "Yue (Premium)" "Lili (Enhanced)" "Meijia (Enhanced)" "Tingting")
  for v in "${preferred[@]}"; do
    voice_available "$v" && echo "$v" && return
  done
  echo "Tingting"
}

if [ -n "$VOICE_ARG" ] && voice_available "$VOICE_ARG"; then
  FINAL_VOICE="$VOICE_ARG"
else
  FINAL_VOICE=$(pick_best_voice)
fi

# ── 队列模式（等待上一条说完）────────────────────────────────
LOCK_FILE="/tmp/voice_notify_speaking.lock"
if [ "$QUEUE_MODE" = true ]; then
  DEADLINE=$(( $(date +%s) + 20 ))
  while [ -f "$LOCK_FILE" ] && [ $(date +%s) -lt $DEADLINE ]; do
    sleep 0.3
  done
fi

# ── 首次使用提醒 ──────────────────────────────────────────────
SETUP_FLAG="${HOME}/.voice_notify_setup_done"
if [ ! -f "$SETUP_FLAG" ]; then
  if ! voice_available "Lili (Premium)" && ! voice_available "Yue (Premium)"; then
    echo ""
    echo "╔══════════════════════════════════════════════════════╗"
    echo "║  Voice Notify — 建议下载高质量语音以获得最佳体验    ║"
    echo "║  运行: bash ~/.claude/skills/voice-notify/scripts/   ║"
    echo "║         setup.sh                                     ║"
    echo "╚══════════════════════════════════════════════════════╝"
  else
    touch "$SETUP_FLAG"
  fi
fi

# ── 播报（trap 确保进程退出时清理锁文件）────────────────────
touch "$LOCK_FILE"
trap 'rm -f "$LOCK_FILE"' EXIT INT TERM
say -v "$FINAL_VOICE" -r "$FINAL_RATE" "$FINAL_MESSAGE"
