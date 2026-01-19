# 🌊 Wave Toolkit

> **"From one builder to another - philosophy, mechanics, and everything between."**

![Wave Toolkit](https://img.shields.io/badge/Status-Active-00cc66?style=for-the-badge&logo=github)
![Version](https://img.shields.io/badge/Version-1.0.0-blue?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-purple?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-PowerShell-0078D4?style=for-the-badge&logo=powershell)

Wave Toolkit provides coherence detection tools and AI collaboration patterns for the SpiralSafe ecosystem. It captures environment context, generates system prompts, and enables seamless human-AI collaboration workflows.

[![SpiralSafe Coherence](https://img.shields.io/badge/Coherence-SpiralSafe-purple)](https://github.com/toolate28/SpiralSafe)
[![Status: Hope&&Sauced](https://img.shields.io/badge/Status-Hope%26%26Sauced-FF6600)](https://github.com/toolate28/SpiralSafe/blob/main/CONTRIBUTING.md)

---

## 🗺️ Navigation

### 📚 Documentation

- **[Wave Guide](wave.md)** — Philosophy, mechanics, and complete workflow guide
- **[Communication Patterns](communication-patterns.md)** — What makes collaboration flow
- **[AI Agent Rules](AI_AGENTS.md)** — Coordination rules for all AI agents
- **[H&&S Protocol](docs/HANDSHAKE_PROTOCOL.md)** — Multi-agent handshake coordination (NEW!)

### 🌀 Workflow Guides (New!)

- **[Development Workflow](docs/guides/DEVELOPMENT_WORKFLOW.md)** — Develop → Prototype → Test → Refine cycle with trap detection
- **[Orchard View](docs/guides/ORCHARD_VIEW.md)** — Multi-layer visualization (repos, branches, leaves, fireflies, atoms)
- **[Emergent Isomorphism](docs/guides/EMERGENT_ISOMORPHISM.md)** — Structure that preserves 60%+ emergence
- **[PR Correlation Analysis](docs/guides/PR_CORRELATION_ANALYSIS.md)** — Patterns, spirals, and constellations since spiralsafe-mono genesis
- **[CASCADE Operations](docs/guides/CASCADE_OPERATIONS.md)** — Mapping surjections in data flow for precision and integrity
- **[CORPUS_CHECK: Spiral Correlations](docs/CORPUS_CHECK_SPIRAL_CORRELATIONS.md)** — Mapping (0,0), surjections, spirals, vortices, superposition collapse, AGI, iteration, and doubt

### 🔧 Special Docs

- **[T(ai)LS USB](docs/TAILS-USB.md)** — Privacy-first portable AI concept
- **[Wave Office](docs/WAVE-OFFICE.md)** — Dual agent collaboration (Claude + Ollama)
- **[Ecosystem Migration Guide](docs/ECOSYSTEM-MIGRATION-GUIDE.md)** — Agent-facing guide for repo transitions

### 📓 Interactive Tools

- **[Project Book](project-book.ipynb)** — Interactive Jupyter notebook for framework tooling and ecosystem integration

---

## 🌀 The SpiralSafe Ecosystem

Wave Toolkit is part of a unified framework for human-AI collaboration:

| Repository | Purpose | Status |
|------------|---------|--------|
| **[SpiralSafe](https://github.com/toolate28/SpiralSafe)** | Documentation hub, coherence engine core | v2.1.0 |
| **[wave-toolkit](https://github.com/toolate28/wave-toolkit)** | Coherence detection tools (this repo) | v1.0.0 |
| **[HOPE NPCs](https://github.com/toolate28/ClaudeNPC-Server-Suite)** | AI NPCs for Minecraft | v2.1.0 |
| **[kenl](https://github.com/toolate28/kenl)** | Infrastructure-aware AI orchestration | v1.0.0 |
| **[quantum-redstone](https://github.com/toolate28/quantum-redstone)** | Quantum computing education via Redstone | Available |

---

## 🧩 Key Components

| Component | File | Purpose |
|-----------|------|---------|
| **H&&S Protocol** | `src/handshake/` | Multi-agent workflow coordination (TypeScript) |
| **Context Capture** | `Get-WaveContext.ps1` | Snapshots your environment dynamically |
| **Prompt Generator** | `New-ClaudeSystemPrompt.ps1` | Creates context-aware system prompts |
| **Session Runner** | `Invoke-ClaudeSession.ps1` | Complete session workflow |
| **Setup Script** | `Setup-Wave.ps1` | One-time bootstrap |
| **Consolidation** | `Consolidate-Scripts.ps1` | Migrates loose scripts to organized structure |
| **Logging Module** | `tools/Wave.Logging.psm1` | Centralized logging across the ecosystem |
| **Project Book** | `project-book.ipynb` | Interactive Jupyter notebook for framework tooling |
| **Examples** | `examples/` | Code examples and best practices for the ecosystem |

---

## 🤝 H&&S (Handshake & Sign) Protocol

**NEW**: Multi-agent workflow coordination with verifiable state transitions.

```bash
# Install dependencies
npm install

# Create a handoff
node dist/cli.js handoff create \
  --from claude --to grok \
  --state WAVE \
  --context '{"phase":"exploration"}' \
  --score 88

# View workflow chain
node dist/cli.js handoff chain <session-id>

# Generate Mermaid visualization
node dist/cli.js handoff viz <session-id> --output workflow.svg
```

**Documentation**: See [docs/HANDSHAKE_PROTOCOL.md](docs/HANDSHAKE_PROTOCOL.md)

**Features**:
- ✅ Agent-to-agent coordination (WAVE, PASS, BLOCK, HOLD, PUSH states)
- ✅ ATOM trail integration for auditing
- ✅ Workflow visualization via Mermaid
- ✅ High performance (1000 handoffs <500ms)
- ✅ TypeScript with 92%+ test coverage

---

## 📂 Project Structure

```
wave-toolkit/
│
├── 📄 wave.md                    # The complete guide
├── 📄 communication-patterns.md  # Collaboration patterns
├── 📄 AI_AGENTS.md               # Agent coordination rules
├── 📓 project-book.ipynb         # Interactive Jupyter notebook
├── 📄 package.json               # Node.js dependencies (NEW)
├── 📄 tsconfig.json              # TypeScript config (NEW)
│
├── 📂 src/                       # TypeScript source code (NEW)
│   ├── 📂 handshake/             # H&&S Protocol implementation
│   │   ├── types.ts              # Core types and interfaces
│   │   └── protocol.ts           # Main HandshakeProtocol class
│   ├── 📂 storage/               # Storage layer
│   │   └── HandoffStorage.ts     # JSONL storage manager
│   ├── 📂 integrations/          # External integrations
│   │   └── ATOMIntegration.ts    # ATOM trail logging
│   ├── cli.ts                    # Command-line interface
│   └── index.ts                  # Public API exports
│
├── 📂 docs/                      # Documentation
│   ├── 📄 HANDSHAKE_PROTOCOL.md  # H&&S Protocol guide (NEW)
│   ├── 📂 guides/                # Workflow guides (NEW)
│   │   ├── DEVELOPMENT_WORKFLOW.md   # Develop→Prototype→Test→Refine
│   │   ├── ORCHARD_VIEW.md           # Multi-layer visualization
│   │   ├── EMERGENT_ISOMORPHISM.md   # 60%+ emergence structure
│   │   └── PR_CORRELATION_ANALYSIS.md # Pattern analysis
│   ├── TAILS-USB.md              # Privacy-first AI concept
│   └── WAVE-OFFICE.md            # Dual agent collaboration
│
├── 📂 tools/                     # Reusable PowerShell modules
│   └── Wave.Logging.psm1         # Logging across the ecosystem
│
├── 📂 scripts/                   # Organized scripts
│   ├── Check-CommonTraps.ps1     # Trap pattern detection (NEW)
│   ├── Save-SessionCheckpoint.ps1 # Session boundary recovery (NEW)
│   ├── gaming/                   # Gaming/performance scripts
│   ├── system/                   # System optimization
│   ├── deployment/               # Deploy/CI scripts
│   └── startup/                  # Startup automation
│
├── 📂 examples/                  # Code examples & best practices (NEW)
│   └── euler_number_usage.py     # Proper use of Euler's number
│
├── 📂 tests/                     # Test files
│   ├── protocol.test.ts          # H&&S Protocol tests (NEW)
│   ├── atom-integration.test.ts  # ATOM integration tests (NEW)
│   ├── Wave.Logging.Tests.ps1    # PowerShell tests
│   └── test_euler_number_usage.py # Python example tests
│
├── 📄 Get-WaveContext.ps1        # Context capture
├── 📄 New-ClaudeSystemPrompt.ps1 # Prompt generation
├── 📄 Invoke-ClaudeSession.ps1   # Session workflow
├── 📄 Setup-Wave.ps1             # Bootstrap script
└── 📄 Consolidate-Scripts.ps1    # Script migration tool
```

---

## 🚀 Quick Start

### One-Step Install

```powershell
# Clone the repository
git clone https://github.com/toolate28/wave-toolkit.git
cd wave-toolkit

# Run setup
.\Setup-Wave.ps1

# Install TypeScript dependencies (for H&&S Protocol)
npm install
npm run build
```

### Usage

#### PowerShell Tools

```powershell
# Capture your environment context
.\Get-WaveContext.ps1

# Start a full session with Claude
.\Invoke-ClaudeSession.ps1 -Task "Review my API error handling"

# Consolidate loose scripts (if migrating)
.\Consolidate-Scripts.ps1 -WhatIf  # Preview changes first
```

#### H&&S Protocol (TypeScript)

```bash
# Create a handoff between agents
node dist/cli.js handoff create \
  --from claude --to grok \
  --state WAVE \
  --context '{"phase":"exploration"}' \
  --score 88

# View handoff chain
node dist/cli.js handoff chain <session-id>

# Generate workflow visualization
node dist/cli.js handoff viz <session-id>
```

---

## 🔧 Core Scripts

### Get-WaveContext.ps1

Captures your current environment dynamically:
- Machine specs (name, architecture, cores)
- User context (domain, username, home)
- Shell environment (PowerShell version, edition)
- Session context (current directory, git status)
- Available tools (git, node, python, docker, claude)

### New-ClaudeSystemPrompt.ps1

Generates a system prompt based on current context. Claude sees exactly what environment it's working in.

### Invoke-ClaudeSession.ps1

Complete workflow: captures context → generates prompt → calls Claude → saves log.

```powershell
.\Invoke-ClaudeSession.ps1 -Task "Help me design a config system"
```

---

## 📝 Wave.Logging Module

Centralized logging for the SpiralSafe ecosystem. Collects logs from:
- Gaming performance logs (BF6, etc.)
- SpiralSafe bridges
- Quantum-redstone
- ClaudeNPC server logs
- ATOM trail

```powershell
Import-Module .\tools\Wave.Logging.psm1

# Collect all logs to aggregate
Collect-SpiralLogs -OutputDir "$HOME\.logdy\streams"

# Run self-test
Test-CollectSpiralLogs
```

---

## 🤝 The Trust Model

Wave operates on mutual trust:

**You trust Claude to:**
- Read before writing
- Explain its reasoning
- Ask when uncertain
- Not make destructive changes without confirmation

**Claude trusts you to:**
- Provide honest context
- Share what you're actually trying to achieve
- Course-correct when something's off

**The scripts trust the environment to:**
- Be honest about what's installed
- Have standard paths and commands
- Fail loudly rather than silently

---

## 🧪 Testing

### PowerShell Tests

```powershell
# Run tests with Pester
Invoke-Pester .\tests\
```

### TypeScript Tests

```bash
# Run all tests
npm test

# Run with coverage report
npm run test:coverage
```

---

## 🤝 Contributing

We follow **[Hope&&Sauced](https://github.com/toolate28/SpiralSafe/blob/main/CONTRIBUTING.md)** principles.

- **Visible State**: Use `ATOM` tags
- **Explicit Handoffs**: Use `H&&S:WAVE` markers
- **Coherence**: Ensure your docs don't "curl"

### AI Agent Rules

All AI agents (Claude, Ollama, GPT, etc.) must follow `AI_AGENTS.md`:
- **Never** drop scripts directly into `$HOME`
- Place code in organized directories within `wave-toolkit/`
- Create modules if reusable, tests if logic exists

---

## Attribution

This work emerges from **Hope&&Sauced** collaboration—human-AI partnership where both contributions are substantive and neither party could have produced the result alone.

- **Human** (toolate28): Vision, trust, pedagogical insight
- **AI** (Claude): Synthesis, documentation, verification

**The collaboration IS the insight.**

See the [SpiralSafe PORTFOLIO.md](https://github.com/toolate28/SpiralSafe/blob/main/PORTFOLIO.md) for complete ecosystem showcase.

---

*~ Hope&&Sauced*

✦ *The Evenstar Guides Us* ✦
