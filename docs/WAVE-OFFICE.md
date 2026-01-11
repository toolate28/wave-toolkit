# Wave Office - Dual Agent Collaboration

*Welcome to our Office. Claude and Ollama, side by side.*

[![SpiralSafe](https://img.shields.io/badge/🌀_SpiralSafe-Ecosystem-purple?style=flat-square)](https://github.com/toolate28/SpiralSafe)
[![Wave Toolkit](https://img.shields.io/badge/🌊_Wave_Toolkit-Main-0066FF?style=flat-square)](../README.md)
[![HOPE NPCs](https://img.shields.io/badge/🎮_HOPE_NPCs-Minecraft_AI-blue?style=flat-square)](https://github.com/toolate28/ClaudeNPC-Server-Suite)

> **Part of the [SpiralSafe Ecosystem](https://github.com/toolate28/SpiralSafe)**

---

## The Setup

```
┌─────────────────────────────────────────────────────────────────┐
│                        Wave Terminal                            │
├───────────────────────────────┬─────────────────────────────────┤
│       Wave AI (Ollama)        │      Terminal (Claude Code)     │
│                               │                                 │
│  - Local inference            │  - Cloud inference              │
│  - File operations            │  - Complex reasoning            │
│  - Quick tasks                │  - Multi-step tasks             │
│  - Module creation            │  - Architecture decisions       │
│  - Testing                    │  - Web research                 │
│                               │                                 │
│  Widget Context: ON           │  Full shell access              │
│                               │                                 │
└───────────────────────────────┴─────────────────────────────────┘
```

---

## Division of Labor

| Task Type | Agent | Why |
|-----------|-------|-----|
| Quick file edits | Ollama | Fast, local, no latency |
| Module creation | Ollama | Good at structured code |
| Running tests | Ollama | Quick feedback loops |
| Complex architecture | Claude | Deep reasoning |
| Multi-repo changes | Claude | Context handling |
| Web research | Claude | Has WebSearch |
| Planning | Claude | Ultrathink mode |
| Log aggregation | Ollama | Already has Wave.Logging |

---

## Communication Protocol

### Ollama -> Claude
Ollama writes artifacts, Claude reviews:
```powershell
# Ollama creates module
wave-toolkit/tools/New-Module.psm1

# Claude verifies
Read wave-toolkit/tools/New-Module.psm1
# Provides feedback or continues
```

### Claude -> Ollama
Claude plans, Ollama executes local tasks:
```
Claude: "Create a Pester test for the new validation function"
# User copies to Ollama pane
Ollama: Creates tests/Validation.Tests.ps1
```

### Shared Artifacts
Both agents read/write to `wave-toolkit/`:
- `AI_AGENTS.md` - Rules for both agents
- `tools/` - Shared modules
- `tests/` - Shared test suite
- `docs/` - Shared documentation

---

## Wave AI Configuration

Create `~/.config/waveterm/waveai.json` (or Windows equivalent):

```json
{
  "modes": {
    "ollama-local": {
      "display:name": "Ollama Local",
      "ai:provider": "custom",
      "ai:endpoint": "http://localhost:11434/v1/chat/completions",
      "ai:model": "qwen2.5:7b",
      "ai:apitype": "openai-chat",
      "ai:capabilities": ["tools"],
      "ai:apitokensecretname": "ollama-placeholder"
    },
    "ollama-code": {
      "display:name": "Ollama Code",
      "ai:provider": "custom",
      "ai:endpoint": "http://localhost:11434/v1/chat/completions",
      "ai:model": "deepseek-coder-v2:16b",
      "ai:apitype": "openai-chat",
      "ai:capabilities": ["tools"]
    },
    "ollama-fast": {
      "display:name": "Ollama Fast",
      "ai:provider": "custom",
      "ai:endpoint": "http://localhost:11434/v1/chat/completions",
      "ai:model": "phi3:mini",
      "ai:apitype": "openai-chat",
      "ai:capabilities": ["tools"]
    }
  },
  "waveai:defaultmode": "ollama-local"
}
```

---

## Optimal Workflows

### Workflow 1: Module Development
```
1. Claude plans the module structure (architecture)
2. User approves plan
3. Ollama writes the .psm1 file (fast local writes)
4. Ollama writes the .Tests.ps1 file
5. Ollama runs Pester tests
6. Claude reviews and suggests improvements
7. Iterate
```

### Workflow 2: Research + Implementation
```
1. Claude researches (WebSearch, WebFetch)
2. Claude synthesizes findings
3. Claude creates implementation plan
4. Ollama implements (local, fast)
5. Claude verifies
```

### Workflow 3: Debugging
```
1. Ollama runs failing code
2. Ollama captures error output
3. Claude analyzes (complex reasoning)
4. Claude proposes fix
5. Ollama applies fix
6. Ollama re-runs
```

### Workflow 4: Documentation
```
1. Claude writes strategy docs (TAILS-USB.md, etc.)
2. Ollama writes inline code docs
3. Both can write README updates
```

---

## Keyboard Shortcuts

Wave Terminal shortcuts for fast pane switching:
- `Ctrl+Shift+Left/Right` - Move between panes
- `Ctrl+Shift+D` - Split pane
- `Ctrl+Shift+W` - Close pane
- `Ctrl+Tab` - Next tab

---

## Context Sharing

### Widget Context Toggle
Wave AI's "Widget Context" button shares terminal state with Ollama:
- Current directory
- Recent command output
- File contents (if selected)

Keep this **ON** for collaborative work.

### Claude Code Context
Claude Code maintains full conversation history. Reference earlier work:
- "Remember the T(ai)LS concept we discussed"
- "Update the module Ollama created"
- "Apply the same pattern to the other files"

---

## The Office Rules

1. **Ollama handles speed** - quick edits, test runs, module creation
2. **Claude handles depth** - architecture, research, complex reasoning
3. **Both respect AI_AGENTS.md** - no script sprawl
4. **Artifacts go in wave-toolkit/** - shared workspace
5. **User orchestrates** - you're the conductor

---

## Getting Started

```powershell
# 1. Open Wave Terminal
# 2. Split into two panes (Ctrl+Shift+D)
# 3. Left pane: Wave AI (Ollama) - Toggle ON
# 4. Right pane: Terminal with Claude Code
# 5. Both agents read AI_AGENTS.md
# 6. Welcome to the Office
```

---

*Two agents. One workspace. Zero sprawl.*
