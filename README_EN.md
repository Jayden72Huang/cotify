<div align="center">

# 🔔 Cotify

**Make Claude Code speak — task completion, errors, agent check-in, all with voice notifications to keep you in the flow.**

[![macOS](https://img.shields.io/badge/macOS-12%2B-blue?logo=apple)](https://www.apple.com/macos/)
[![Zero Dependencies](https://img.shields.io/badge/dependencies-zero-brightgreen)](.)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

[Quick Start](#quick-start) · [中文](README.md) · [Features](#core-features) · [Agent Team](#agent-team-scenario) · [Website](https://cotify.space)

<a href="https://cotify.space">
  <img src="assets/preview.png" alt="Cotify Landing Page" width="100%" />
</a>

</div>

---

## What It Does

Go grab coffee while Claude Code runs tasks — **it will speak up and tell you when it's done**. No need to stare at the screen.

```
Boss, all agents checked in, team ready!          ← Agent team check-in
Hmm... an error occurred, please check            ← Error with gentle comfort
Awesome! Task complete, deployment done!           ← Celebration on completion
3 of 7 done, keep it up!                          ← Real-time progress
It's late, all tasks completed                    ← Late-night time awareness
```

**Zero dependencies**: Uses only macOS built-in `say` and `afplay`. Install and go — no API keys needed.

---

## Quick Start

### Step 1: Install the Skill

```bash
# In Claude Code
/skills add voice-notify
```

### Step 2: Download Recommended Voice (First Time)

```bash
bash ~/.claude/skills/voice-notify/scripts/setup.sh
```

The script auto-detects your environment and guides you to download `Lili (Premium)` — the closest voice to Siri's Chinese tone.

**Manual path:**
```
System Settings → Accessibility → Spoken Content → Manage Voices → Chinese (Mainland) → Lili (Premium) ⬇
```

### Step 3: Enable in Claude Code

```
You: Enable voice notifications
Claude: Sure! Which mode would you prefer?
  · milestone (default) — announces on task completion, errors, achievements
  · full — announces every step
  · completion — only on final completion
```

---

## Core Features

### 🎭 5 Emotion Presets

Different scenarios auto-adjust speech rate and filler words to sound more human:

| Preset | Rate | Tone | Use Case |
|--------|------|------|---------|
| `celebrate` | 200 | Wow! Amazing! Let's go! | Build pass, task done |
| `comfort` | 165 | Hmm... it's okay, it'll be fine | Errors, failures |
| `encourage` | 210 | Keep going! Push through! | Progress updates |
| `alert` | 210 | Attention! Warning! | Critical errors |
| `normal` | 200 | Calm and natural | General notifications |

```bash
bash voice.sh "Build passed" --preset=celebrate
bash voice.sh "Error detected, please check" --preset=comfort
```

### ⚡ 3 Vibe Levels

```bash
--vibe=chill   # Minimal, no filler words, pure announcements
--vibe=normal  # Default, ~60% chance of random filler words
--vibe=hype    # Full power, always adds filler words
```

### 🕐 Time Awareness

```bash
bash voice.sh "Task complete" --time-aware
# Late night → "It's so late, task complete"
# Morning   → "Good morning, task complete"
# Evening   → "Good evening, task complete"
```

### 🔇 Anti-Spam & Anti-Interrupt

```bash
# Same event type only plays once within 10 seconds
bash voice.sh "Progress update" --debounce=10

# Multiple messages queue up, no interrupting each other
bash voice.sh "First message" --queue
bash voice.sh "Second message" --queue
```

---

## Agent Team Scenario

When multiple agents collaborate, each role has a unique voice:

| Agent | Voice |
|-------|------|
| PM | Lili (Premium) |
| DEV | Yue (Premium) |
| Designer | Sinji |
| Researcher | Meijia (Enhanced) |
| QA | Meijia |

**Team check-in example:**

```bash
# Each agent arrives
bash sfx.sh checkin
bash voice.sh "Boss, PM is online, reporting for duty!" "Lili (Premium)" --preset=normal --queue

# All ready
bash sfx.sh celebrate
bash voice.sh "All agents checked in, awaiting orders!" --preset=celebrate --queue
```

---

## Sound Effects

| Command | Sound | When |
|---------|-------|------|
| `sfx.sh celebrate` | Hero | Major task done |
| `sfx.sh success` | Glass | Build/test pass |
| `sfx.sh error` | Sosumi | Critical error |
| `sfx.sh levelup` | Purr | Achievement unlocked |
| `sfx.sh coin` | Pop | Small win, commit |
| `sfx.sh checkin` | Morse | Agent check-in |
| `sfx.sh warning` | Basso | Non-critical warning |

---

## Mode Switching (vn command)

Switch voice modes anytime during development without interrupting Claude Code:

```bash
vn quiet    # 🔈 Quiet: only completion + critical errors
vn normal   # 🔊 Normal (default)
vn mute     # 🔇 Complete silence
vn hype     # 📢 Full power: every step, max filler words
vn status   # Check current mode
```

Shortcuts: `vn q` / `vn n` / `vn m` / `vn h` / `vn s`

> Running `bash setup.sh` will auto-install the `vn` alias to your shell config.

---

## System Requirements

| Item | Requirement |
|------|-------------|
| OS | macOS 12 Monterey or later |
| Dependencies | None (uses built-in `say` + `afplay`) |
| Recommended Voice | Lili Premium (download in System Settings) |

> **About Siri voices:** macOS `say` command uses an independent voice engine from Siri and cannot call Siri voices directly. `Lili (Premium)` is currently the closest system voice to Siri's Chinese tone.

---

## Full Parameter Reference

```
voice.sh "<message>" [voice] [rate] [flags...]

Flags:
  --preset=celebrate|comfort|encourage|alert|normal
  --vibe=chill|normal|hype
  --time-aware          Time-of-day prefix
  --queue               Queue for sequential playback
  --debounce=<sec>      Anti-spam, play only once in N seconds
  --no-filler           Disable filler word injection
```

---

## File Structure

```
voice-notify/
├── SKILL.md              # Claude Code skill config
├── README.md             # Chinese docs
├── README_EN.md          # English docs
└── scripts/
    ├── voice.sh          # Core TTS script
    ├── sfx.sh            # System sound effects
    ├── vn.sh             # Quick mode switching
    ├── setup.sh          # First-time setup & detection
    └── demo.sh           # Feature demo
```

---

## FAQ

**Q: Voice isn't in Chinese?**
A: Run `bash setup.sh` to check if the recommended voice is downloaded.

**Q: No sound at all?**
A: Check system volume and whether macOS "Do Not Disturb" is enabled.

**Q: Can I use it on Linux?**
A: Currently macOS only. Linux support (via espeak) is planned.

**Q: Does it consume Claude API tokens?**
A: No. All announcements run locally with no AI API calls.

---

## License

MIT © 2025

---

*If this skill makes your vibe coding even better, give it a ⭐ Star!*
