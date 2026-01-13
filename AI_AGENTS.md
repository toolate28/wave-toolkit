# AI Agent Coordination Rules

*This file tells ALL AI agents (Claude, Ollama, GPT, etc.) where to put things.*

[![SpiralSafe](https://img.shields.io/badge/🌀_SpiralSafe-Ecosystem-purple?style=flat-square)](https://github.com/toolate28/SpiralSafe)
[![Wave Toolkit](https://img.shields.io/badge/🌊_Wave_Toolkit-Main-0066FF?style=flat-square)](README.md)
[![HOPE NPCs](https://img.shields.io/badge/🎮_HOPE_NPCs-Minecraft_AI-blue?style=flat-square)](https://github.com/toolate28/ClaudeNPC-Server-Suite)

> **Part of the [SpiralSafe Ecosystem](https://github.com/toolate28/SpiralSafe)**

---

## The Golden Rule

**NEVER drop scripts directly into `$HOME` (`C:\Users\*).**

All code must go into organized directories within `wave-toolkit/` or project-specific repos.

---

## Directory Structure

```text
C:\Users\iamto\wave-toolkit\
├── tools\                    # Reusable PowerShell modules (.psm1)
│   └── *.psm1
├── scripts\                  # Executable scripts (.ps1)
│   ├── gaming\               # Gaming/performance scripts
│   ├── system\               # System optimization
│   ├── deployment\           # Deploy/CI scripts
│   └── startup\              # Startup automation
├── tests\                    # Pester tests
│   └── *.Tests.ps1
├── prompts\                  # AI prompt templates
└── docs\                     # Documentation
```

---

## Placement Rules

| Type | Location | Example |
|------|----------|---------|
| Reusable module | `tools/` | `Wave.Logging.psm1` |
| Gaming script | `scripts/gaming/` | `Optimize-Gaming.ps1` |
| System script | `scripts/system/` | `SYSTEM_OPTIMIZER.ps1` |
| Deployment | `scripts/deployment/` | `PARALLEL_DEPLOY.ps1` |
| Startup script | `scripts/startup/` | `STARTUP_AUTOMATION_COMPLETE.ps1` |
| Tests | `tests/` | `Wave.Logging.Tests.ps1` |
| AI prompts | `prompts/` | `wave-system.md` |

---

## Before Writing Files

1. **Check this file exists** - if you're in `wave-toolkit/`, read `AI_AGENTS.md`
2. **Determine the category** - what type of script is this?
3. **Place in correct directory** - never in `$HOME` root
4. **Create module if reusable** - `.psm1` with `Export-ModuleMember`
5. **Add test if logic exists** - `tests/*.Tests.ps1`

---

## Existing Scripts to Migrate

The following scripts in `$HOME` should be consolidated:

### Gaming (`scripts/gaming/`)
- `BATTLEFIELD_OPTIMIZER.ps1`
- `BF6_Performance_Monitor.ps1`
- `Optimize-Gaming.ps1`

### System (`scripts/system/`)
- `SYSTEM_OPTIMIZER.ps1`
- `CREATE_SYMLINKS.ps1`

### Deployment (`scripts/deployment/`)
- `PARALLEL_DEPLOY.ps1`
- `AutoUpdate-SpiralSafe.ps1`

### Startup (`scripts/startup/`)
- `STARTUP_AUTOMATION_COMPLETE.ps1`
- `mcstart.ps1`
- `Dashboard.ps1`

### Wave Toolkit Root (already here)
- `Get-WaveContext.ps1`
- `Invoke-ClaudeSession.ps1`
- `New-ClaudeSystemPrompt.ps1`
- `Setup-Wave.ps1`

### Profile (stays in $HOME)
- `ENHANCED_PROFILE.ps1` - OK, this is a profile
- `system_aliases.cmd` - OK, sourced by shell

---

## For Ollama Specifically

You're doing great with module structure. Keep:
- Creating `.psm1` files in `tools/`
- Adding tests in `tests/`
- Using `Export-ModuleMember`

Don't:
- Create scripts in `$HOME` root
- Duplicate functionality that exists in modules
- Create one-off scripts without tests

---

## For Claude Code Specifically

Same rules apply. Additional notes:
- You have full shell access - verify file locations before writing
- Run `Get-ChildItem $HOME -Filter *.ps1` to check for sprawl
- Consolidate before creating new scripts

---

## Verification

Run this to check for sprawl:
```powershell
# Should return ONLY profile-related files
Get-ChildItem $HOME -Filter "*.ps1" | Where-Object { $_.Name -notmatch "PROFILE|profile" }
```

If this returns results, something violated the rules.

---

*This file is the source of truth for AI agent behavior in this workspace.*
