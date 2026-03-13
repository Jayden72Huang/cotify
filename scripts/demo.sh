#!/bin/bash
# =============================================================
# voice-notify Demo — 逐一展示所有功能
# Usage: bash demo.sh [--fast]   快速模式缩短间隔
# =============================================================

SKILL_DIR="$(cd "$(dirname "$0")/.." && pwd)"
V="$SKILL_DIR/scripts/voice.sh"
S="$SKILL_DIR/scripts/sfx.sh"

DELAY=2
[[ "$1" == "--fast" ]] && DELAY=1

BOLD="\033[1m"
CYAN="\033[0;36m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
RED="\033[0;31m"
DIM="\033[2m"
RESET="\033[0m"

section() {
  echo ""
  echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo -e "${CYAN}${BOLD}  $1${RESET}"
  echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  echo ""
}

step() {
  echo -e "${DIM}  $ $1${RESET}"
}

label() {
  echo -e "  ${GREEN}▶${RESET} $1"
}

pause() {
  sleep "$DELAY"
}

# ── 开场 ──────────────────────────────────────────────────────
clear
echo ""
echo -e "${BOLD}  🔔 voice-notify Demo${RESET}"
echo -e "${DIM}  让 Claude Code 开口说话${RESET}"
echo ""
sleep 1

# ── 1. 音效展示 ──────────────────────────────────────────────
section "1/6  系统音效"

EFFECTS=("start:会话开始" "checkin:Agent报到" "success:构建通过" "coin:小胜利" "error:严重错误" "celebrate:大任务完成" "levelup:成就解锁")

for item in "${EFFECTS[@]}"; do
  effect="${item%%:*}"
  desc="${item##*:}"
  label "$desc"
  step "sfx.sh $effect"
  bash "$S" "$effect"
  sleep 0.8
done
pause

# ── 2. 情感预设 ──────────────────────────────────────────────
section "2/6  情感预设（5 种场景自动调节语速 + 语气词）"

label "normal — 通用通知"
step "voice.sh \"系统初始化完成\" --preset=normal"
bash "$V" "系统初始化完成" --preset=normal
pause

label "celebrate — 任务完成"
step "voice.sh \"构建通过，一切正常\" --preset=celebrate"
bash "$S" success &
bash "$V" "构建通过，一切正常" --preset=celebrate
pause

label "comfort — 出错安抚"
step "voice.sh \"出现了错误，请检查\" --preset=comfort"
bash "$S" error &
bash "$V" "出现了错误，请检查" --preset=comfort
pause

label "encourage — 进度鼓励"
step "voice.sh \"已完成三项，共七项\" --preset=encourage"
bash "$S" coin &
bash "$V" "已完成三项，共七项" --preset=encourage
pause

label "alert — 严重警告"
step "voice.sh \"发现严重错误，需要立即介入\" --preset=alert --no-filler"
bash "$S" error &
bash "$V" "发现严重错误，需要立即介入" --preset=alert --no-filler
pause

# ── 3. Vibe Level ────────────────────────────────────────────
section "3/6  情绪强度（chill / normal / hype）"

label "chill — 极简，无语气词"
step "voice.sh \"部署完成\" --preset=celebrate --vibe=chill"
bash "$V" "部署完成" --preset=celebrate --vibe=chill
pause

label "normal — 约 60% 概率加语气词"
step "voice.sh \"部署完成\" --preset=celebrate --vibe=normal"
bash "$V" "部署完成" --preset=celebrate --vibe=normal
pause

label "hype — 必定加语气词"
step "voice.sh \"部署完成\" --preset=celebrate --vibe=hype"
bash "$V" "部署完成" --preset=celebrate --vibe=hype
pause

# ── 4. 时段感知 ──────────────────────────────────────────────
section "4/6  时段感知（根据当前时间自动加前缀）"

HOUR=$(date +%H | sed 's/^0//')
if   [ "$HOUR" -ge 5  ] && [ "$HOUR" -lt 10 ]; then
  echo -e "  ${YELLOW}当前时段：早上（05:00–10:00）→ 前缀「早啊，」${RESET}"
elif [ "$HOUR" -ge 22 ] || [ "$HOUR" -lt 5 ]; then
  echo -e "  ${YELLOW}当前时段：深夜（22:00–05:00）→ 前缀「这么晚啊，」${RESET}"
elif [ "$HOUR" -ge 18 ] && [ "$HOUR" -lt 22 ]; then
  echo -e "  ${YELLOW}当前时段：傍晚（18:00–22:00）→ 前缀「傍晚了，」${RESET}"
else
  echo -e "  ${YELLOW}当前时段：白天（10:00–18:00）→ 无前缀${RESET}"
fi
echo ""

label "不开启 --time-aware"
step "voice.sh \"所有任务执行完毕\" --preset=celebrate"
bash "$V" "所有任务执行完毕" --preset=celebrate --vibe=chill
pause

label "开启 --time-aware"
step "voice.sh \"所有任务执行完毕\" --preset=celebrate --time-aware"
bash "$S" celebrate &
bash "$V" "所有任务执行完毕" --preset=celebrate --time-aware --vibe=chill
pause

# ── 5. Agent 团队报到 ────────────────────────────────────────
section "5/6  Agent 团队报到"

AGENTS=("PM:Lili (Premium)" "开发者:Yue (Premium)" "设计师:Sinji")

for item in "${AGENTS[@]}"; do
  role="${item%%:*}"
  voice="${item##*:}"
  label "$role 报到（${voice}）"
  step "voice.sh \"老板，${role}已上线，向您报到！\" \"${voice}\" --queue"
  bash "$S" checkin &
  bash "$V" "老板，${role}已上线，向您报到！" "$voice" --preset=normal --queue
  sleep 0.5
done

label "全员就绪"
step "voice.sh \"全员报到完毕，团队就绪！\" --preset=celebrate --queue"
bash "$S" celebrate &
bash "$V" "全员报到完毕，团队就绪，等待老板指令！" --preset=celebrate --queue
pause

# ── 6. 完整场景模拟 ──────────────────────────────────────────
section "6/6  完整场景：从开始到完成"

label "会话开始"
bash "$S" start &
bash "$V" "会话已启动，准备就绪" --preset=normal
pause

label "构建通过"
bash "$S" success &
bash "$V" "构建通过，一切正常" --preset=celebrate
pause

label "进度更新"
bash "$S" coin &
bash "$V" "已完成五项，共七项，再坚持一下" --preset=encourage
pause

label "成就解锁"
bash "$S" levelup &
bash "$V" "成就解锁！五连胜，手感火热！" --preset=celebrate --vibe=hype
pause

label "任务完成"
bash "$S" celebrate &
bash "$V" "所有任务执行完毕" --preset=celebrate --time-aware
pause

# ── 结束 ──────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${GREEN}${BOLD}  ✅ Demo 完成！${RESET}"
echo ""
echo -e "  ${DIM}安装: /skills add voice-notify${RESET}"
echo -e "  ${DIM}配置: bash ~/.claude/skills/voice-notify/scripts/setup.sh${RESET}"
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo ""
