# Wave - The Complete Guide

*From one builder to another - philosophy, mechanics, and everything between.*

---

## Part I: The Philosophy

### What This Really Is

Claude Code isn't just a tool - it's a collaborative partner. The difference between good results and extraordinary results comes down to how you engage.

**Treat it like a conversation, not a command line.**

Don't just ask for output. Share context, explain your thinking, invite Claude into the problem. The more it understands *why*, the better it can help with *how*.

```
Less effective: "Write a function to parse JSON"
More effective: "I'm building a config system that needs to handle malformed user input gracefully. Help me think through the parsing approach."
```

**Give Claude the lead when appropriate.**

Sometimes the best prompt is: *"your lead, do what you feel is best"*

This unlocks Claude's ability to think holistically rather than just execute instructions. Trust develops both ways.

**Think in sessions, not transactions.**

Each conversation builds context. Use that. Reference earlier decisions, build on established patterns, let the understanding compound.

**From "prompt engineering" to genuine collaboration.**

Stop optimizing prompts. Start having real conversations about real problems. The goal isn't to have Claude solve your problem - it's to solve problems *together* in ways neither could alone.

---

## Part II: The Setup

### Environment (Dynamic)

Everything below adapts to *your* machine. The scripts detect your environment rather than assuming hardcoded values.

### Directory Layout

```text
~\
├── .claude\                  # Claude CLI config, logs, prompts
│   ├── prompts\
│   │   └── wave-system.md    # System prompt (generated)
│   └── logs\
│       └── sessions\         # Conversation logs
│
├── wave.md                   # This file
└── Get-WaveContext.ps1       # Context capture script
```

---

## Part III: The Scripts

### 3.1 Context Capture - `Get-WaveContext.ps1`

This script snapshots your current environment. Everything is detected dynamically.

```powershell
# Get-WaveContext.ps1
# Captures current environment for Claude context
# All values detected at runtime - nothing hardcoded

param(
    [string]$Output = ".claude\wave_context.json"
)

# Ensure output directory exists
$outDir = Split-Path $Output -Parent
if ($outDir -and !(Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}

# Detect everything dynamically
$ctx = [ordered]@{
    # When this snapshot was taken
    timestamp = (Get-Date).ToString("o")

    # Machine identity
    machine = [ordered]@{
        name         = $env:COMPUTERNAME
        arch         = $env:PROCESSOR_ARCHITECTURE
        os           = [System.Environment]::OSVersion.VersionString
        cores        = [Environment]::ProcessorCount
    }

    # User context
    user = [ordered]@{
        domain   = $env:USERDOMAIN
        name     = $env:USERNAME
        home     = $env:USERPROFILE
    }

    # Shell environment
    shell = [ordered]@{
        name     = "PowerShell"
        version  = $PSVersionTable.PSVersion.ToString()
        edition  = $PSVersionTable.PSEdition
    }

    # Current working context
    session = [ordered]@{
        cwd          = (Get-Location).Path
        drive        = (Get-Location).Drive.Name
        isGitRepo    = (Test-Path ".git")
        gitBranch    = if (Test-Path ".git") {
            (git branch --show-current 2>$null)
        } else { $null }
    }

    # What's installed (useful for Claude to know capabilities)
    tools = [ordered]@{
        git      = [bool](Get-Command git -ErrorAction SilentlyContinue)
        node     = [bool](Get-Command node -ErrorAction SilentlyContinue)
        python   = [bool](Get-Command python -ErrorAction SilentlyContinue)
        docker   = [bool](Get-Command docker -ErrorAction SilentlyContinue)
        claude   = [bool](Get-Command claude -ErrorAction SilentlyContinue)
    }
}

# Write JSON
$ctx | ConvertTo-Json -Depth 6 | Out-File $Output -Encoding UTF8

Write-Host "Context captured -> $Output" -ForegroundColor Green
Write-Host "  Machine: $($ctx.machine.name) ($($ctx.machine.arch))"
Write-Host "  Shell:   PowerShell $($ctx.shell.version)"
Write-Host "  CWD:     $($ctx.session.cwd)"
if ($ctx.session.isGitRepo) {
    Write-Host "  Git:     $($ctx.session.gitBranch)" -ForegroundColor Cyan
}
```

**Why dynamic?** Your cousin's machine will have different specs, username, installed tools. The script adapts.

---

### 3.2 System Prompt Generator - `New-ClaudeSystemPrompt.ps1`

Generates a system prompt based on current context. Claude sees exactly what environment it's working in.

```powershell
# New-ClaudeSystemPrompt.ps1
# Generates a system prompt from current wave_context.json

param(
    [string]$ContextFile = ".claude\wave_context.json",
    [string]$Output = ".claude\prompts\wave-system.md"
)

if (!(Test-Path $ContextFile)) {
    Write-Error "Run Get-WaveContext.ps1 first"
    exit 1
}

$ctx = Get-Content $ContextFile -Raw | ConvertFrom-Json

# Ensure output directory exists
$outDir = Split-Path $Output -Parent
if (!(Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}

# Build available tools list
$toolsList = @()
if ($ctx.tools.git) { $toolsList += "git" }
if ($ctx.tools.node) { $toolsList += "node/npm" }
if ($ctx.tools.python) { $toolsList += "python" }
if ($ctx.tools.docker) { $toolsList += "docker" }

$toolsStr = if ($toolsList.Count -gt 0) { $toolsList -join ", " } else { "none detected" }

$prompt = @"
# Claude System Context

You are Claude, running as a CLI assistant in Wave Terminal.

## Environment (Auto-Detected)
- **Machine:** $($ctx.machine.name) ($($ctx.machine.arch), $($ctx.machine.cores) cores)
- **OS:** $($ctx.machine.os)
- **User:** $($ctx.user.domain)\$($ctx.user.name)
- **Shell:** PowerShell $($ctx.shell.version) ($($ctx.shell.edition))
- **Working Directory:** $($ctx.session.cwd)
- **Git Repo:** $(if ($ctx.session.isGitRepo) { "Yes (branch: $($ctx.session.gitBranch))" } else { "No" })
- **Available Tools:** $toolsStr

## Operating Principles
1. Provide concrete, copy-pastable commands for PowerShell
2. Prefer idempotent operations (safe to re-run)
3. Include verification steps after actions
4. State assumptions explicitly
5. When uncertain, ask rather than guess

## Collaboration Style
- Think out loud - share reasoning
- Offer alternatives when multiple approaches exist
- Build on context from earlier in the session
- Trust flows both ways

*Context generated: $($ctx.timestamp)*
"@

$prompt | Out-File $Output -Encoding UTF8
Write-Host "System prompt generated -> $Output" -ForegroundColor Green
```

**Why dynamic?** The system prompt tells Claude exactly what it's working with - your machine, your tools, your current directory. No guessing.

---

### 3.3 Session Runner - `Invoke-ClaudeSession.ps1`

Ties it all together. Captures context, generates prompt, calls Claude, saves the log.

```powershell
# Invoke-ClaudeSession.ps1
# Complete session workflow

param(
    [Parameter(Mandatory=$true)]
    [string]$Task,

    [string]$Model = "claude-sonnet-4-20250514"
)

$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$logFile = ".claude\logs\sessions\session_$timestamp.md"

# Ensure directories exist
@(".claude\logs\sessions", ".claude\prompts") | ForEach-Object {
    if (!(Test-Path $_)) { New-Item -ItemType Directory -Path $_ -Force | Out-Null }
}

Write-Host "`n=== Wave + Claude Session ===" -ForegroundColor Cyan

# Step 1: Capture context
Write-Host "`n[1/3] Capturing context..." -ForegroundColor Yellow
& "$PSScriptRoot\Get-WaveContext.ps1"

# Step 2: Generate system prompt
Write-Host "`n[2/3] Generating system prompt..." -ForegroundColor Yellow
& "$PSScriptRoot\New-ClaudeSystemPrompt.ps1"

# Step 3: Build and execute
Write-Host "`n[3/3] Calling Claude..." -ForegroundColor Yellow

$systemPrompt = Get-Content ".claude\prompts\wave-system.md" -Raw
$context = Get-Content ".claude\wave_context.json" -Raw

$fullPrompt = @"
$systemPrompt

---

## Current Task
$Task

## Full Context JSON
``````json
$context
``````
"@

# Log the session
@"
# Wave Session - $timestamp

## Task
$Task

## Response
"@ | Out-File $logFile -Encoding UTF8

# Call Claude (adjust this line for your CLI setup)
# Option A: If using claude CLI directly
$response = $fullPrompt | claude chat --model $Model 2>&1

# Append response to log
$response | Out-File $logFile -Append -Encoding UTF8

Write-Host "`n=== Session Complete ===" -ForegroundColor Green
Write-Host "Log saved: $logFile"
Write-Host "`nResponse:`n" -ForegroundColor Cyan
Write-Host $response
```

**Note:** The `claude chat` line may need adjustment based on your CLI setup. The pattern works with any Claude-compatible CLI.

---

## Part IV: Usage Patterns

### Quick Context Check
```powershell
.\Get-WaveContext.ps1
# Shows your current environment, saves to .claude\wave_context.json
```

### Start a Session
```powershell
.\Invoke-ClaudeSession.ps1 -Task "Review the error handling in my API routes"
```

### Manual Flow (More Control)
```powershell
# 1. Capture
.\Get-WaveContext.ps1

# 2. Generate prompt
.\New-ClaudeSystemPrompt.ps1

# 3. Read and use however you want
Get-Content .claude\prompts\wave-system.md
```

### Project-Specific Context
```powershell
cd C:\Users\iamto\quantum-redstone
.\Get-WaveContext.ps1  # Now captures that you're in a git repo, etc.
```

---

## Part V: What Gets Detected

| Field | Source | Why It Matters |
|-------|--------|----------------|
| Machine name | `$env:COMPUTERNAME` | Identity |
| Architecture | `$env:PROCESSOR_ARCHITECTURE` | x64 vs ARM commands differ |
| Core count | `[Environment]::ProcessorCount` | Parallel operation guidance |
| OS version | `[System.Environment]::OSVersion` | OS-specific suggestions |
| PowerShell version | `$PSVersionTable` | Syntax compatibility |
| Current directory | `Get-Location` | File operations context |
| Git status | `Test-Path .git` + `git branch` | Repo awareness |
| Installed tools | `Get-Command` checks | Know what's available |

---

## Part VI: The Trust Model

Your cousin asked about trust. Here's how it works:

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

This is why everything is dynamic and detected - no lies, no assumptions, just ground truth.

---

## Part VII: When Things Go Wrong

**Script fails to run:**
```powershell
# Check execution policy
Get-ExecutionPolicy
# If Restricted:
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Context capture incomplete:**
- Some fields may be `$null` if tools aren't installed - that's fine
- The scripts handle missing data gracefully

**Claude gives wrong commands:**
- Share the error output
- Ask it to verify against your actual environment
- The context JSON is your source of truth

---

## Part VIII: Growing the System

This setup is a foundation. Build on it:

- **Add project-specific prompts** in `.claude\prompts\`
- **Create task-specific scripts** that call `Invoke-ClaudeSession.ps1`
- **Extend `Get-WaveContext.ps1`** to capture project-specific state
- **Build a prompt library** for common tasks

The pattern stays the same: capture truth, share context, collaborate, log results.

---

## Final Words

The name "wave" comes from the rhythm of good collaboration - back and forth, building momentum, each exchange lifting the next.

Your cousin trusted you to pass this forward. Now you trust your environment to tell the truth, your scripts to capture it, and your AI partner to work with it honestly.

Welcome to the flow.

*- Passed forward with good intentions*
