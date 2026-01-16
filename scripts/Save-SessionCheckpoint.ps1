<#
.SYNOPSIS
    Creates and manages session checkpoints for recovery after token limits or session loss.

.DESCRIPTION
    This script helps maintain continuity across AI agent session boundaries by:
    - Saving checkpoints with current state
    - Detecting incomplete work from previous sessions
    - Generating recovery context for new sessions
    
    Based on patterns from SpiralSafe ecosystem analysis where session
    boundary errors (token limits, crashes) caused work loss.

.PARAMETER Action
    Action to perform: Save, Load, Recover, Clean

.PARAMETER Note
    Note to attach to checkpoint (for Save action)

.PARAMETER Force
    Force overwrite of existing checkpoint

.EXAMPLE
    .\Save-SessionCheckpoint.ps1 -Action Save -Note "Completed auth module"
    Saves current state as a checkpoint.

.EXAMPLE
    .\Save-SessionCheckpoint.ps1 -Action Recover
    Generates recovery context for a new session.

.EXAMPLE
    .\Save-SessionCheckpoint.ps1 -Action Load
    Shows the last saved checkpoint.

.NOTES
    H&&S:WAVE | Hope&&Sauced
    
    Token limit patterns addressed:
    - Session dies mid-task → checkpoint preserves state
    - Context lost → recovery template rebuilds context
    - Partial commits → checkpoint tracks what's done vs pending
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Save", "Load", "Recover", "Clean", "Check")]
    [string]$Action,
    
    [Parameter()]
    [string]$Note = "",
    
    [switch]$Force
)

$ErrorActionPreference = "Continue"
$checkpointFile = Join-Path $PSScriptRoot "../.session-checkpoint.json"
$checkpointDir = Split-Path $checkpointFile -Parent

# Ensure we're in the repo root context
$repoRoot = git rev-parse --show-toplevel 2>$null
if ($repoRoot) {
    $checkpointFile = Join-Path $repoRoot ".session-checkpoint.json"
}

function Get-GitState {
    $state = @{
        Branch = git branch --show-current 2>$null
        RemoteUrl = git remote get-url origin 2>$null
        LastCommit = git log -1 --format="%h %s" 2>$null
        StagedFiles = @(git diff --cached --name-only 2>$null)
        ModifiedFiles = @(git diff --name-only 2>$null)
        UntrackedFiles = @(git ls-files --others --exclude-standard 2>$null)
        StashCount = (git stash list 2>$null | Measure-Object).Count
        Ahead = 0
        Behind = 0
    }
    
    # Check ahead/behind
    $trackingInfo = git rev-list --left-right --count HEAD...@{upstream} 2>$null
    if ($trackingInfo) {
        $parts = $trackingInfo -split '\s+'
        $state.Ahead = [int]$parts[0]
        $state.Behind = [int]$parts[1]
    }
    
    return $state
}

function Save-Checkpoint {
    param([string]$Note)
    
    $gitState = Get-GitState
    
    $checkpoint = @{
        Version = "1.0"
        Timestamp = Get-Date -Format "o"
        TimestampHuman = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Note = $Note
        Git = $gitState
        WorkingDirectory = Get-Location | Select-Object -ExpandProperty Path
        Environment = @{
            PowerShellVersion = $PSVersionTable.PSVersion.ToString()
            OS = if ($IsWindows) { "Windows" } elseif ($IsMacOS) { "macOS" } else { "Linux" }
            User = $env:USERNAME ?? $env:USER
        }
        RecoveryHints = @()
    }
    
    # Add recovery hints based on state
    if ($gitState.StagedFiles.Count -gt 0) {
        $checkpoint.RecoveryHints += "Staged changes exist - commit or unstage"
    }
    if ($gitState.ModifiedFiles.Count -gt 0) {
        $checkpoint.RecoveryHints += "Uncommitted changes in: $($gitState.ModifiedFiles -join ', ')"
    }
    if ($gitState.StashCount -gt 0) {
        $checkpoint.RecoveryHints += "$($gitState.StashCount) stash(es) exist - check git stash list"
    }
    if ($gitState.Ahead -gt 0) {
        $checkpoint.RecoveryHints += "$($gitState.Ahead) commit(s) not pushed"
    }
    
    $checkpoint | ConvertTo-Json -Depth 5 | Out-File $checkpointFile -Encoding UTF8
    
    Write-Host "📍 Checkpoint saved: $($checkpoint.TimestampHuman)" -ForegroundColor Green
    if ($Note) {
        Write-Host "   Note: $Note" -ForegroundColor Cyan
    }
    Write-Host "   Branch: $($gitState.Branch)" -ForegroundColor DarkGray
    Write-Host "   Last commit: $($gitState.LastCommit)" -ForegroundColor DarkGray
    
    if ($checkpoint.RecoveryHints.Count -gt 0) {
        Write-Host "`n⚠️  Recovery hints:" -ForegroundColor Yellow
        $checkpoint.RecoveryHints | ForEach-Object {
            Write-Host "   • $_" -ForegroundColor Yellow
        }
    }
}

function Load-Checkpoint {
    if (-not (Test-Path $checkpointFile)) {
        Write-Host "❌ No checkpoint found at: $checkpointFile" -ForegroundColor Red
        Write-Host "   Create one with: .\Save-SessionCheckpoint.ps1 -Action Save -Note 'description'" -ForegroundColor DarkGray
        return $null
    }
    
    $checkpoint = Get-Content $checkpointFile -Raw | ConvertFrom-Json
    
    Write-Host "📋 Last Checkpoint" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "Time: $($checkpoint.TimestampHuman)" -ForegroundColor White
    Write-Host "Note: $($checkpoint.Note)" -ForegroundColor White
    Write-Host ""
    Write-Host "Git State:" -ForegroundColor Cyan
    Write-Host "  Branch: $($checkpoint.Git.Branch)" -ForegroundColor DarkGray
    Write-Host "  Last commit: $($checkpoint.Git.LastCommit)" -ForegroundColor DarkGray
    Write-Host "  Staged: $($checkpoint.Git.StagedFiles.Count) files" -ForegroundColor DarkGray
    Write-Host "  Modified: $($checkpoint.Git.ModifiedFiles.Count) files" -ForegroundColor DarkGray
    Write-Host "  Stashes: $($checkpoint.Git.StashCount)" -ForegroundColor DarkGray
    
    if ($checkpoint.RecoveryHints.Count -gt 0) {
        Write-Host "`nRecovery Hints:" -ForegroundColor Yellow
        $checkpoint.RecoveryHints | ForEach-Object {
            Write-Host "  • $_" -ForegroundColor Yellow
        }
    }
    
    return $checkpoint
}

function Generate-RecoveryContext {
    $checkpoint = $null
    if (Test-Path $checkpointFile) {
        $checkpoint = Get-Content $checkpointFile -Raw | ConvertFrom-Json
    }
    
    $currentState = Get-GitState
    $repoName = Split-Path (git rev-parse --show-toplevel 2>$null) -Leaf
    
    Write-Host "`n📋 Session Recovery Context" -ForegroundColor Cyan
    Write-Host "Copy this to your new session:" -ForegroundColor DarkGray
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    
    $recoveryContext = @"

## Session Recovery Context

**Repository:** $repoName
**Branch:** $($currentState.Branch)
**Current Time:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

"@

    if ($checkpoint) {
        $recoveryContext += @"
### Previous Session
**Checkpoint Time:** $($checkpoint.TimestampHuman)
**Note:** $($checkpoint.Note)
**Last Commit (then):** $($checkpoint.Git.LastCommit)

"@
    }

    $recoveryContext += @"
### Current State
**Last Commit:** $($currentState.LastCommit)
**Staged Files:** $($currentState.StagedFiles.Count) files
**Modified Files:** $($currentState.ModifiedFiles.Count) files
**Unpushed Commits:** $($currentState.Ahead)
**Stashes:** $($currentState.StashCount)

"@

    if ($currentState.ModifiedFiles.Count -gt 0) {
        $recoveryContext += "**Files with uncommitted changes:**`n"
        $currentState.ModifiedFiles | ForEach-Object {
            $recoveryContext += "- $_`n"
        }
        $recoveryContext += "`n"
    }

    if ($currentState.StagedFiles.Count -gt 0) {
        $recoveryContext += "**Files staged for commit:**`n"
        $currentState.StagedFiles | ForEach-Object {
            $recoveryContext += "- $_`n"
        }
        $recoveryContext += "`n"
    }

    # Get recent commits for context
    $recentCommits = git log --oneline -5 2>$null
    if ($recentCommits) {
        $recoveryContext += "### Recent Commits`n"
        $recoveryContext += "``````"
        $recoveryContext += "`n$recentCommits`n"
        $recoveryContext += "```````n`n"
    }

    $recoveryContext += @"
### Recovery Actions Needed
"@

    $actions = @()
    if ($currentState.ModifiedFiles.Count -gt 0) {
        $actions += "- [ ] Review and commit uncommitted changes"
    }
    if ($currentState.StagedFiles.Count -gt 0) {
        $actions += "- [ ] Complete or unstage staged changes"
    }
    if ($currentState.StashCount -gt 0) {
        $actions += "- [ ] Check stashes: ``git stash list``"
    }
    if ($currentState.Ahead -gt 0) {
        $actions += "- [ ] Push $($currentState.Ahead) unpushed commit(s)"
    }
    if ($actions.Count -eq 0) {
        $actions += "- [x] No immediate recovery actions needed"
    }
    
    $actions | ForEach-Object {
        $recoveryContext += "$_`n"
    }

    $recoveryContext += @"

### Quick Commands
``````powershell
# Check current state
git status

# See recent changes
git log --oneline -10

# Continue from checkpoint
# (Add your specific next steps here)
``````

"@

    Write-Host $recoveryContext
    
    # Also save to a file for easy copying
    $recoveryFile = Join-Path (Split-Path $checkpointFile -Parent) ".session-recovery.md"
    $recoveryContext | Out-File $recoveryFile -Encoding UTF8
    Write-Host "`n💾 Recovery context saved to: $recoveryFile" -ForegroundColor Green
}

function Check-SessionHealth {
    Write-Host "`n🔍 Session Health Check" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    
    $issues = @()
    $warnings = @()
    $state = Get-GitState
    
    # Check for uncommitted work
    $totalChanges = $state.StagedFiles.Count + $state.ModifiedFiles.Count
    if ($totalChanges -gt 10) {
        $warnings += "⚠️  Large number of uncommitted changes ($totalChanges files)"
        $warnings += "   Consider committing in smaller chunks to prevent loss"
    }
    
    # Check for unpushed commits
    if ($state.Ahead -gt 3) {
        $warnings += "⚠️  $($state.Ahead) unpushed commits"
        $warnings += "   Push frequently to prevent loss on session end"
    }
    
    # Check checkpoint age
    if (Test-Path $checkpointFile) {
        $checkpoint = Get-Content $checkpointFile -Raw | ConvertFrom-Json
        $checkpointAge = (Get-Date) - [DateTime]$checkpoint.Timestamp
        if ($checkpointAge.TotalMinutes -gt 30) {
            $warnings += "⚠️  Last checkpoint is $(([int]$checkpointAge.TotalMinutes)) minutes old"
            $warnings += "   Consider saving a new checkpoint"
        } else {
            Write-Host "✅ Recent checkpoint exists ($(([int]$checkpointAge.TotalMinutes)) min ago)" -ForegroundColor Green
        }
    } else {
        $issues += "❌ No checkpoint exists"
        $issues += "   Create one: .\Save-SessionCheckpoint.ps1 -Action Save -Note 'description'"
    }
    
    # Check git state
    if ($state.Branch) {
        Write-Host "✅ On branch: $($state.Branch)" -ForegroundColor Green
    } else {
        $issues += "❌ Not in a git repository or detached HEAD"
    }
    
    if ($state.StashCount -gt 0) {
        $warnings += "⚠️  $($state.StashCount) stash(es) exist - don't forget them"
    }
    
    # Report
    if ($issues.Count -gt 0) {
        Write-Host "`nIssues:" -ForegroundColor Red
        $issues | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    }
    
    if ($warnings.Count -gt 0) {
        Write-Host "`nWarnings:" -ForegroundColor Yellow
        $warnings | ForEach-Object { Write-Host "  $_" -ForegroundColor Yellow }
    }
    
    if ($issues.Count -eq 0 -and $warnings.Count -eq 0) {
        Write-Host "`n✅ Session health good - safe to continue" -ForegroundColor Green
    }
    
    # Recommendation
    Write-Host "`n💡 Tip: Save checkpoints every 15-20 minutes or before risky operations" -ForegroundColor Cyan
}

function Clean-Checkpoints {
    $files = @(
        (Join-Path (Split-Path $checkpointFile -Parent) ".session-checkpoint.json"),
        (Join-Path (Split-Path $checkpointFile -Parent) ".session-recovery.md")
    )
    
    foreach ($file in $files) {
        if (Test-Path $file) {
            Remove-Item $file -Force
            Write-Host "🗑️  Removed: $file" -ForegroundColor DarkGray
        }
    }
    
    Write-Host "✅ Checkpoint files cleaned" -ForegroundColor Green
}

# Main execution
switch ($Action) {
    "Save" {
        Save-Checkpoint -Note $Note
    }
    "Load" {
        Load-Checkpoint | Out-Null
    }
    "Recover" {
        Generate-RecoveryContext
    }
    "Check" {
        Check-SessionHealth
    }
    "Clean" {
        Clean-Checkpoints
    }
}
