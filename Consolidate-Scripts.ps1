# Consolidate-Scripts.ps1
# Migrates loose scripts from $HOME into organized wave-toolkit structure
# Safe to re-run - checks if source exists before moving

param(
    [switch]$WhatIf,
    [switch]$Force
)

$toolkit = "$HOME\wave-toolkit"
$moved = 0
$skipped = 0

# Migration map: source -> destination
$migrations = @{
    # Gaming
    "BATTLEFIELD_OPTIMIZER.ps1"    = "scripts\gaming"
    "BF6_Performance_Monitor.ps1"  = "scripts\gaming"
    "Optimize-Gaming.ps1"          = "scripts\gaming"

    # System
    "SYSTEM_OPTIMIZER.ps1"         = "scripts\system"
    "CREATE_SYMLINKS.ps1"          = "scripts\system"

    # Deployment
    "PARALLEL_DEPLOY.ps1"          = "scripts\deployment"
    "AutoUpdate-SpiralSafe.ps1"    = "scripts\deployment"

    # Startup
    "STARTUP_AUTOMATION_COMPLETE.ps1" = "scripts\startup"
    "mcstart.ps1"                  = "scripts\startup"
    "Dashboard.ps1"                = "scripts\startup"

    # Wave toolkit root (these should stay in root, not HOME)
    "Get-WaveContext.ps1"          = "."
    "Invoke-ClaudeSession.ps1"     = "."
    "New-ClaudeSystemPrompt.ps1"   = "."
    "Setup-Wave.ps1"               = "."
}

Write-Host "`n=== Script Consolidation ===" -ForegroundColor Cyan
if ($WhatIf) {
    Write-Host "(WhatIf mode - no files will be moved)`n" -ForegroundColor Yellow
}

foreach ($script in $migrations.Keys) {
    $source = Join-Path $HOME $script
    $destDir = Join-Path $toolkit $migrations[$script]
    $dest = Join-Path $destDir $script

    if (!(Test-Path $source)) {
        # Source doesn't exist in HOME (already moved or never existed)
        continue
    }

    if (Test-Path $dest) {
        if ($Force) {
            Write-Host "  OVERWRITE: $script -> $($migrations[$script])/" -ForegroundColor Yellow
            if (!$WhatIf) {
                Move-Item $source $dest -Force
                $moved++
            }
        } else {
            Write-Host "  SKIP (exists): $script" -ForegroundColor DarkGray
            $skipped++
        }
    } else {
        Write-Host "  MOVE: $script -> $($migrations[$script])/" -ForegroundColor Green
        if (!$WhatIf) {
            Move-Item $source $dest
            $moved++
        }
    }
}

# Check for remaining scripts in HOME
$remaining = Get-ChildItem $HOME -Filter "*.ps1" |
    Where-Object { $_.Name -notmatch "PROFILE|profile" }

Write-Host "`n=== Summary ===" -ForegroundColor Cyan
Write-Host "  Moved: $moved"
Write-Host "  Skipped: $skipped"

if ($remaining.Count -gt 0) {
    Write-Host "`n  Remaining in HOME (not in migration map):" -ForegroundColor Yellow
    $remaining | ForEach-Object { Write-Host "    - $($_.Name)" }
    Write-Host "`n  Add these to AI_AGENTS.md migration map if needed."
} else {
    Write-Host "`n  HOME is clean!" -ForegroundColor Green
}

Write-Host ""
