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

---

## User QoL (Quality of Life) Considerations on Install

*SAIF-processes/methodology — Structured AI Integration Framework*

When setting up the Wave Toolkit or any SpiralSafe ecosystem repository, follow these installation QoL principles to ensure smooth onboarding and consistent execution across sessions.

### 1. Absolute References

**Always use absolute paths** rather than relative paths in scripts and configurations:

```powershell
# ✅ Good: Absolute references
$WaveToolkitPath = "$HOME\wave-toolkit"
$ScriptPath = Join-Path $WaveToolkitPath "scripts\system"

# ❌ Bad: Relative paths that break when working directory changes
$ScriptPath = ".\scripts\system"
```

**Why it matters:**
- AI agents may execute from different working directories
- Cron jobs and scheduled tasks don't inherit the expected `$PWD`
- Sub-processes spawned by agents start with unpredictable paths
- Cross-session persistence requires stable path anchors

**Use these environment-aware patterns:**
```powershell
# Repository root detection (PowerShell 7+ ternary, or if-else for 5.1)
$gitRoot = git rev-parse --show-toplevel 2>$null
$RepoRoot = if ($gitRoot) { $gitRoot } else { $PSScriptRoot }

# Cross-platform home directory
$UserHome = if ($IsWindows) { $env:USERPROFILE } else { $env:HOME }

# Canonical Wave Toolkit path
$WaveRoot = Join-Path $UserHome "wave-toolkit"
```

### 2. Shell Aliases for Cross-Platform Support

**Create aliases for native shell platforms** to ensure consistent command availability:

```powershell
# PowerShell aliases for Unix-like commands
Set-Alias -Name ll -Value Get-ChildItem -Scope Global
Set-Alias -Name grep -Value Select-String -Scope Global
Set-Alias -Name touch -Value New-Item -Scope Global
Set-Alias -Name which -Value Get-Command -Scope Global

# Export for persistence
Export-ModuleMember -Alias * -Function *
```

```cmd
:: CMD aliases (system_aliases.cmd)
@echo off
doskey ll=dir /a $*
doskey grep=findstr $*
doskey cat=type $*
doskey clear=cls
```

**Binding across execution frame 'event horizons':**

When an AI agent spawns processes or hands off to sub-agents, aliases may not persist. To ensure binding:

1. **Profile-level loading**: Add aliases to `$PROFILE` for automatic loading
2. **Explicit sourcing**: Source alias files at the start of each session
3. **Function wrappers**: Prefer functions over aliases for complex operations (functions export more reliably)

```powershell
# Ensure aliases persist across PowerShell sessions
if (Test-Path "$HOME\wave-toolkit\scripts\system\aliases.ps1") {
    . "$HOME\wave-toolkit\scripts\system\aliases.ps1"
}
```

### 3. Python Caching for CI/CD Workflows

**Use `actions/setup-python@v5` with pip caching** to improve install performance in GitHub Actions:

```yaml
# .github/workflows/ci.yml
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
          cache: 'pip'  # Enable pip dependency caching
          cache-dependency-path: '**/requirements*.txt'
      
      - name: Install dependencies
        run: pip install -r requirements.txt
```

**Why caching matters for QoL:**
- Reduces CI run time by 30-60 seconds per workflow
- Decreases load on package registries (pip, npm, etc.)
- Provides consistent dependency resolution across runs
- Enables faster iteration during development

**For other package managers:**
```yaml
# Node.js with npm cache
- uses: actions/setup-node@v4
  with:
    node-version: '20'
    cache: 'npm'

# PowerShell module caching (manual)
- name: Cache PowerShell modules
  uses: actions/cache@v4
  with:
    path: ~/.local/share/powershell/Modules
    key: ${{ runner.os }}-pwsh-${{ hashFiles('**/requirements.psd1') }}
```

### 4. Bootstrap Verification Checklist

When running `Setup-Wave.ps1` or similar bootstrap scripts, verify:

| Check | Status | Recovery Action |
|-------|--------|-----------------|
| Git available | `git --version` | Install Git for Windows |
| PowerShell 7+ | `$PSVersionTable.PSVersion` | Install pwsh from Microsoft Store |
| Execution policy allows scripts | `Get-ExecutionPolicy` | `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` |
| Required directories exist | `Test-Path $WaveRoot` | Run bootstrap again |
| Profile is writable | `Test-Path $PROFILE` | Create profile directory |

### 5. Event Horizon Boundaries

**"Event horizons"** in this context refer to execution boundaries where context may be lost:

- **New shell session**: Aliases, functions, and variables reset
- **Sub-process spawn**: Child processes don't inherit parent's aliases
- **Agent handoff**: When one AI agent delegates to another
- **Scheduled execution**: Cron/Task Scheduler runs have minimal environment

**Mitigation strategies:**

```powershell
# 1. Environment variable persistence
[Environment]::SetEnvironmentVariable("WAVE_ROOT", $WaveRoot, "User")

# 2. Session checkpoint (for agent handoffs)
@{
    Timestamp = Get-Date -Format "o"
    WaveRoot = $WaveRoot
    Branch = git branch --show-current
    Aliases = Get-Alias | Select-Object Name, Definition
} | ConvertTo-Json | Out-File ".wave-session.json"

# 3. Reload on session start
if (Test-Path ".wave-session.json") {
    $session = Get-Content ".wave-session.json" | ConvertFrom-Json
    Write-Host "Resuming Wave session from $($session.Timestamp)"
}
```

---

## Related Documentation

- **[Development Workflow](docs/guides/DEVELOPMENT_WORKFLOW.md)** — Session boundary errors and recovery patterns
- **[Wave Guide](wave.md)** — Philosophy and complete workflow guide
- **[Setup Script](Setup-Wave.ps1)** — One-time bootstrap implementation
