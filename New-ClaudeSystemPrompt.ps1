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

$gitStatus = if ($ctx.session.isGitRepo) { "Yes (branch: $($ctx.session.gitBranch))" } else { "No" }

$prompt = @"
# Claude System Context

You are Claude, running as a CLI assistant in Wave Terminal.

## Environment (Auto-Detected)
- **Machine:** $($ctx.machine.name) ($($ctx.machine.arch), $($ctx.machine.cores) cores)
- **OS:** $($ctx.machine.os)
- **User:** $($ctx.user.domain)\$($ctx.user.name)
- **Shell:** PowerShell $($ctx.shell.version) ($($ctx.shell.edition))
- **Working Directory:** $($ctx.session.cwd)
- **Git Repo:** $gitStatus
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
