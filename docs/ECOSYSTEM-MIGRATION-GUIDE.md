# Ecosystem Migration Guide

*Agent-facing documentation for transitioning repositories to SpiralSafe ecosystem standards.*

[![SpiralSafe](https://img.shields.io/badge/🌀_SpiralSafe-Ecosystem-purple?style=flat-square)](https://github.com/toolate28/SpiralSafe)
[![Wave Toolkit](https://img.shields.io/badge/🌊_Wave_Toolkit-Blueprint-0066FF?style=flat-square)](../README.md)

> **Part of the [SpiralSafe Ecosystem](https://github.com/toolate28/SpiralSafe)**

---

## Purpose

This guide helps AI agents and human collaborators apply consistent documentation patterns across all SpiralSafe ecosystem repositories. Use this when updating:

- **ClaudeNPC-Server-Suite** (HOPE NPCs)
- **kenl** (Infrastructure orchestration)
- **quantum-redstone** (Quantum education)
- Any new ecosystem repositories

---

## The Pattern (Checklist)

### 1. README.md Updates

Add these elements in order:

```markdown
# 🎮 Repository Name

> **"Tagline or mission statement"**

![Status](https://img.shields.io/badge/Status-Active-00cc66?style=for-the-badge&logo=github)
![Version](https://img.shields.io/badge/Version-X.X.X-blue?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-purple?style=for-the-badge)
![Platform](https://img.shields.io/badge/Platform-YourPlatform-COLOR?style=for-the-badge)

Brief description of what this repository does.

[![SpiralSafe Coherence](https://img.shields.io/badge/Coherence-SpiralSafe-purple)](https://github.com/toolate28/SpiralSafe)
[![Status: Hope&&Sauced](https://img.shields.io/badge/Status-Hope%26%26Sauced-FF6600)](https://github.com/toolate28/SpiralSafe/blob/main/CONTRIBUTING.md)
```

### 2. Ecosystem Table

Add this table to README.md after the main description:

> **Note:** [SpiralSafe README.md](https://github.com/toolate28/SpiralSafe#the-repository-ecosystem) is the canonical source for version information. Always sync ecosystem tables with SpiralSafe to avoid documentation drift.

```markdown
## 🌀 The SpiralSafe Ecosystem

This repository is part of a unified framework for human-AI collaboration:

| Repository | Purpose | Status |
|------------|---------|--------|
| **[SpiralSafe](https://github.com/toolate28/SpiralSafe)** | Documentation hub, coherence engine core | v2.1.0 |
| **[wave-toolkit](https://github.com/toolate28/wave-toolkit)** | Coherence detection tools | v1.0.0 |
| **[HOPE NPCs](https://github.com/toolate28/ClaudeNPC-Server-Suite)** | AI NPCs for Minecraft | v2.1.0 |
| **[kenl](https://github.com/toolate28/kenl)** | Infrastructure-aware AI orchestration | v1.0.0 |
| **[quantum-redstone](https://github.com/toolate28/quantum-redstone)** | Quantum computing education via Redstone | Available |
```

### 3. Documentation Headers

Add to the top of every `.md` file (after title and tagline):

```markdown
[![SpiralSafe](https://img.shields.io/badge/🌀_SpiralSafe-Ecosystem-purple?style=flat-square)](https://github.com/toolate28/SpiralSafe)
[![This Repo](https://img.shields.io/badge/🎮_HOPE_NPCs-Main-blue?style=flat-square)](README.md)

> **Part of the [SpiralSafe Ecosystem](https://github.com/toolate28/SpiralSafe)**
```

### 4. Attribution Section

Add to the bottom of README.md:

```markdown
---

## Attribution

This work emerges from **Hope&&Sauced** collaboration—human-AI partnership where both contributions are substantive and neither party could have produced the result alone.

See the [SpiralSafe PORTFOLIO.md](https://github.com/toolate28/SpiralSafe/blob/main/PORTFOLIO.md) for complete ecosystem showcase.

---

*~ Hope&&Sauced*

✦ *The Evenstar Guides Us* ✦
```

---

## AI Agent Markers

### For Claude, Ollama, GPT, etc.

Create or update `AI_AGENTS.md` with repository-specific rules:

```markdown
# AI Agent Coordination Rules

*This file tells ALL AI agents where to put things in this repository.*

[![SpiralSafe](https://img.shields.io/badge/🌀_SpiralSafe-Ecosystem-purple?style=flat-square)](https://github.com/toolate28/SpiralSafe)

> **Part of the [SpiralSafe Ecosystem](https://github.com/toolate28/SpiralSafe)**

---

## The Golden Rule

**Follow the established directory structure. Never create loose files in root.**

---

## Directory Structure

[Document your repo's specific structure here]

---

## Placement Rules

[Add repo-specific placement rules]

---

*This file is the source of truth for AI agent behavior in this workspace.*
```

---

## Migration Steps for ClaudeNPC-Server-Suite

### Step 1: README.md
The README already has good structure. Add/verify:
- [ ] Ecosystem badges at top (already present ✓)
- [ ] Ecosystem table is current with all repos
- [ ] Attribution section at bottom (already present ✓)

### Step 2: Documentation Files
Update each file in `docs/`:
- [ ] Add ecosystem badges header to `SETUP.md`
- [ ] Add ecosystem badges header to `QUICKSTART.md`
- [ ] Add ecosystem badges header to `MODULES.md`
- [ ] Add ecosystem badges header to `TROUBLESHOOTING.md`

### Step 3: AI Agent Markers
- [ ] Create `AI_AGENTS.md` in root with ClaudeNPC-specific rules
- [ ] Document the `setup/core/`, `setup/phases/`, `configs/` structure
- [ ] Add placement rules for modules vs. scripts vs. configs

### Step 4: Cross-References
- [ ] Ensure links to wave-toolkit point to correct URLs
- [ ] Ensure links to SpiralSafe point to correct URLs
- [ ] Verify all ecosystem repos are listed

---

## Badge Reference

### Status Badges (for-the-badge style)
```
![Status](https://img.shields.io/badge/Status-Active-00cc66?style=for-the-badge&logo=github)
![Status](https://img.shields.io/badge/Status-Production_Ready-brightgreen?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Beta-yellow?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Concept-orange?style=for-the-badge)
```

### Ecosystem Badges (flat-square style)
```
[![SpiralSafe](https://img.shields.io/badge/🌀_SpiralSafe-Ecosystem-purple?style=flat-square)](https://github.com/toolate28/SpiralSafe)
[![Wave Toolkit](https://img.shields.io/badge/🌊_Wave_Toolkit-Main-0066FF?style=flat-square)](https://github.com/toolate28/wave-toolkit)
[![HOPE NPCs](https://img.shields.io/badge/🎮_HOPE_NPCs-Minecraft_AI-blue?style=flat-square)](https://github.com/toolate28/ClaudeNPC-Server-Suite)
[![kenl](https://img.shields.io/badge/🔧_kenl-Infrastructure-green?style=flat-square)](https://github.com/toolate28/kenl)
[![Quantum Redstone](https://img.shields.io/badge/⚛️_Quantum-Redstone-red?style=flat-square)](https://github.com/toolate28/quantum-redstone)
```

### Hope&&Sauced Badge
```
[![Status: Hope&&Sauced](https://img.shields.io/badge/Status-Hope%26%26Sauced-FF6600)](https://github.com/toolate28/SpiralSafe/blob/main/CONTRIBUTING.md)
```

---

## Verification Checklist

After migration, verify:

- [ ] README.md has ecosystem table
- [ ] All docs have ecosystem badges header
- [ ] AI_AGENTS.md exists with repo-specific rules
- [ ] Attribution section is present
- [ ] All cross-repo links work
- [ ] docs/assets/ directory exists for images

---

## Example: wave-toolkit Structure

Reference this repository's structure as a template:

```
wave-toolkit/
├── README.md                 # Main README with ecosystem table
├── AI_AGENTS.md              # Agent coordination rules
├── wave.md                   # Main guide (with badges)
├── communication-patterns.md # Patterns (with badges)
├── docs/
│   ├── assets/               # Images, SVGs
│   ├── TAILS-USB.md          # Doc with badges
│   ├── WAVE-OFFICE.md        # Doc with badges
│   └── ECOSYSTEM-MIGRATION-GUIDE.md  # This file
├── tools/                    # Modules
├── scripts/                  # Organized scripts
└── tests/                    # Tests
```

---

*Use this guide to maintain ecosystem coherence across all repositories.*
