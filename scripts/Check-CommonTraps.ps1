<#
.SYNOPSIS
    Checks for common development trap patterns before committing.

.DESCRIPTION
    This script detects negative space errors and common traps identified
    from SpiralSafe ecosystem git log analysis. Run before committing to
    catch issues early.

.PARAMETER Verbose
    Show detailed output for each check.

.PARAMETER Fix
    Attempt to fix simple issues automatically (like branch cleanup suggestions).

.EXAMPLE
    .\Check-CommonTraps.ps1
    Quick check for common traps.

.EXAMPLE
    .\Check-CommonTraps.ps1 -Verbose
    Detailed check with explanations.

.NOTES
    Based on patterns from:
    - docs/reports/GIT_INSIGHTS_ANALYSIS.md
    - docs/reports/analysis/claude-code-issues-analysis.md
    - docs/USER_JOURNEY_GAP_ANALYSIS.md

    H&&S:WAVE | Hope&&Sauced
#>

[CmdletBinding()]
param(
    [switch]$Fix
)

$ErrorActionPreference = "Continue"
$traps = @()
$warnings = @()
$fixes = @()

Write-Host "`n🌀 Wave Toolkit - Common Trap Detection" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

# ============================================================================
# CHECK 1: Repository Context
# Pattern: Working in wrong repository (most common user error)
# ============================================================================
Write-Verbose "Checking repository context..."

try {
    $remote = git remote get-url origin 2>$null
    if ($remote) {
        if ($remote -notmatch "wave-toolkit") {
            $traps += @{
                Level = "ERROR"
                Check = "Repository Context"
                Issue = "Not in wave-toolkit repository"
                Detail = "Current remote: $remote"
                Fix = "Verify you're in the correct repository before making changes"
            }
        } else {
            Write-Verbose "✓ Repository context verified: wave-toolkit"
        }
    } else {
        $warnings += @{
            Level = "WARN"
            Check = "Repository Context"
            Issue = "Could not determine remote URL"
            Detail = "Git remote not configured or not in a git repository"
        }
    }
} catch {
    $warnings += @{
        Level = "WARN"
        Check = "Repository Context"
        Issue = "Git check failed"
        Detail = $_.Exception.Message
    }
}

# ============================================================================
# CHECK 2: Branch Status
# Pattern: Dual identity confusion, working on wrong branch
# ============================================================================
Write-Verbose "Checking branch status..."

try {
    $currentBranch = git branch --show-current 2>$null
    if ($currentBranch -eq "main") {
        $warnings += @{
            Level = "WARN"
            Check = "Branch Status"
            Issue = "Working directly on main branch"
            Detail = "Consider using a feature branch for changes"
            Fix = "git checkout -b feature/your-feature-name"
        }
    } else {
        Write-Verbose "✓ On feature branch: $currentBranch"
    }
} catch {
    Write-Verbose "Could not determine current branch"
}

# ============================================================================
# CHECK 3: "Initial Plan" Commits
# Pattern: 15 empty "Initial plan" commits observed in SpiralSafe
# ============================================================================
Write-Verbose "Checking for 'Initial plan' commits..."

try {
    $recentCommits = git log --oneline -10 2>$null
    $initialPlanCount = ($recentCommits | Select-String "Initial plan" | Measure-Object).Count
    
    if ($initialPlanCount -gt 0) {
        $warnings += @{
            Level = "WARN"
            Check = "Commit Quality"
            Issue = "'Initial plan' commits detected ($initialPlanCount)"
            Detail = "These commits typically have no content and pollute git history"
            Fix = "Consider squashing before merge: git rebase -i HEAD~$($initialPlanCount + 1)"
        }
    } else {
        Write-Verbose "✓ No 'Initial plan' noise commits found"
    }
} catch {
    Write-Verbose "Could not check commit history"
}

# ============================================================================
# CHECK 4: Branch Explosion
# Pattern: 40+ stale branches observed in SpiralSafe
# ============================================================================
Write-Verbose "Checking branch count..."

try {
    $allBranches = git branch -a 2>$null
    $branchCount = ($allBranches | Measure-Object).Count
    
    if ($branchCount -gt 30) {
        $warnings += @{
            Level = "WARN"
            Check = "Branch Hygiene"
            Issue = "Branch explosion detected: $branchCount branches"
            Detail = "Many branches can cause confusion and slow git operations"
            Fix = "Clean up merged branches: git branch --merged main | Select-String -NotMatch 'main' | ForEach-Object { git branch -d `$_.Trim() }"
        }
    } elseif ($branchCount -gt 20) {
        Write-Verbose "⚠ Branch count elevated: $branchCount branches"
    } else {
        Write-Verbose "✓ Branch count healthy: $branchCount branches"
    }
} catch {
    Write-Verbose "Could not count branches"
}

# ============================================================================
# CHECK 5: Staged Changes - Platform Assumptions
# Pattern: python3 vs python, hardcoded paths, Desktop references
# ============================================================================
Write-Verbose "Checking staged changes for platform issues..."

try {
    $stagedDiff = git diff --cached 2>$null
    
    if ($stagedDiff) {
        # Check for python3 (Windows incompatible)
        if ($stagedDiff -match "python3\b") {
            $warnings += @{
                Level = "WARN"
                Check = "Platform Compatibility"
                Issue = "'python3' found in staged changes"
                Detail = "Windows uses 'python' not 'python3'"
                Fix = "Use 'python' or check platform: if (`$IsWindows) { 'python' } else { 'python3' }"
            }
        }
        
        # Check for hardcoded Windows paths
        if ($stagedDiff -match "C:\\Users") {
            $traps += @{
                Level = "ERROR"
                Check = "Hardcoded Paths"
                Issue = "Hardcoded Windows paths found"
                Detail = "C:\Users paths are not portable"
                Fix = "Use `$env:USERPROFILE or `$HOME instead"
            }
        }
        
        # Check for Desktop references
        if ($stagedDiff -match "Desktop") {
            $warnings += @{
                Level = "WARN"
                Check = "Output Location"
                Issue = "Desktop path references found"
                Detail = "Desktop paths are not reproducible or backed up"
                Fix = "Output to repository directories instead"
            }
        }
        
        Write-Verbose "✓ Staged changes checked for platform issues"
    }
} catch {
    Write-Verbose "Could not check staged changes"
}

# ============================================================================
# CHECK 6: Security Patterns
# Pattern: Reactive security fixes, exposed secrets
# ============================================================================
Write-Verbose "Checking for security patterns..."

try {
    $stagedDiff = git diff --cached 2>$null
    
    if ($stagedDiff) {
        # Check for potential secrets
        $secretPatterns = @(
            "(api[_-]?key|apikey)\s*[:=]\s*['""]?[a-zA-Z0-9]",
            "(password|passwd|pwd)\s*[:=]\s*['""]?[a-zA-Z0-9]",
            "(secret|token)\s*[:=]\s*['""]?[a-zA-Z0-9]",
            "sk-[a-zA-Z0-9]{20,}",  # OpenAI-style key
            "Bearer [a-zA-Z0-9\-_]+\.[a-zA-Z0-9\-_]+"  # JWT
        )
        
        foreach ($pattern in $secretPatterns) {
            if ($stagedDiff -match $pattern) {
                $traps += @{
                    Level = "ERROR"
                    Check = "Security"
                    Issue = "Potential secret detected in staged changes"
                    Detail = "Pattern matched: sensitive credential pattern"
                    Fix = "Remove secrets and use environment variables instead"
                }
                break
            }
        }
    }
    
    Write-Verbose "✓ Security patterns checked"
} catch {
    Write-Verbose "Could not check for security patterns"
}

# ============================================================================
# CHECK 7: Git Identity
# Pattern: Dual identity confusion (toolated vs toolate28)
# ============================================================================
Write-Verbose "Checking git identity..."

try {
    $userName = git config user.name 2>$null
    $userEmail = git config user.email 2>$null
    
    if (-not $userName -or -not $userEmail) {
        $warnings += @{
            Level = "WARN"
            Check = "Git Identity"
            Issue = "Git user identity not configured"
            Detail = "Commits may appear under unexpected names"
            Fix = "git config user.name 'YourName' && git config user.email 'your@email.com'"
        }
    } else {
        Write-Verbose "✓ Git identity configured: $userName <$userEmail>"
    }
} catch {
    Write-Verbose "Could not check git identity"
}

# ============================================================================
# CHECK 8: Uncommitted Changes
# Pattern: Silent failures, incomplete work
# ============================================================================
Write-Verbose "Checking for uncommitted changes..."

try {
    $status = git status --porcelain 2>$null
    $unstagedCount = ($status | Where-Object { $_ -match "^ M|^\?\?" } | Measure-Object).Count
    $stagedCount = ($status | Where-Object { $_ -match "^M |^A " } | Measure-Object).Count
    
    if ($unstagedCount -gt 10) {
        $warnings += @{
            Level = "WARN"
            Check = "Uncommitted Changes"
            Issue = "Many unstaged changes: $unstagedCount files"
            Detail = "Large changesets are harder to review and debug"
            Fix = "Consider committing in smaller, logical chunks"
        }
    }
    
    Write-Verbose "✓ Status: $stagedCount staged, $unstagedCount unstaged"
} catch {
    Write-Verbose "Could not check git status"
}

# ============================================================================
# CHECK 9: CASCADE Opportunities
# Pattern: Imprecise mathematical operations, missing divergence detection
# ============================================================================
Write-Verbose "Checking for CASCADE operation opportunities..."

try {
    $stagedDiff = git diff --cached 2>$null
    
    if ($stagedDiff) {
        # Check for pow(2.71x, ...) patterns (various approximations of e^x)
        # Matches 2.71, 2.718, 2.7182, 2.71828, etc. with any following parameters
        if ($stagedDiff -match "pow\s*\(\s*2\.71[0-9]*\s*,") {
            $warnings += @{
                Level = "WARN"
                Check = "CASCADE: Numerical Precision"
                Issue = "Found pow(2.71..., x) - approximation of e^x"
                Detail = "Consider using exact exponential: math.exp(x) or [Math]::Exp(x)"
                Fix = "See docs/guides/CASCADE_OPERATIONS.md for refactoring guide"
            }
        }
        
        # Check for Math.Pow with e approximation (PowerShell/C#)
        # Matches various approximations: 2.71, 2.718, 2.7182, etc. with comma separator
        if ($stagedDiff -match "\[Math\]::Pow\s*\(\s*2\.71[0-9]*\s*,") {
            $warnings += @{
                Level = "WARN"
                Check = "CASCADE: Numerical Precision"
                Issue = "Found [Math]::Pow(2.71..., x) - approximation of e^x"
                Detail = "Use [Math]::Exp(x) for exact exponential calculation"
                Fix = "Replace with: [Math]::Exp(x)"
            }
        }
        
        # Check for Python files to suggest import analysis
        $pythonFiles = git diff --cached --name-only 2>$null | Where-Object { $_ -match "\.py$" }
        if ($pythonFiles) {
            $warnings += @{
                Level = "INFO"
                Check = "CASCADE: Code Hygiene"
                Issue = "Python files modified"
                Detail = "Consider checking for unused imports"
                Fix = "Run: pylint --disable=all --enable=unused-import ."
            }
        }
    }
    
    Write-Verbose "✓ CASCADE opportunities checked"
} catch {
    Write-Verbose "Could not check for CASCADE opportunities"
}

# ============================================================================
# REPORT
# ============================================================================

Write-Host ""

# Report errors (traps)
if ($traps.Count -gt 0) {
    Write-Host "🚨 ERRORS ($($traps.Count)):" -ForegroundColor Red
    foreach ($trap in $traps) {
        Write-Host "  ✖ $($trap.Check): $($trap.Issue)" -ForegroundColor Red
        if ($VerbosePreference -eq "Continue" -or $true) {
            Write-Host "    Detail: $($trap.Detail)" -ForegroundColor DarkGray
            if ($trap.Fix) {
                Write-Host "    Fix: $($trap.Fix)" -ForegroundColor Yellow
            }
        }
    }
    Write-Host ""
}

# Report warnings
if ($warnings.Count -gt 0) {
    Write-Host "⚠️  WARNINGS ($($warnings.Count)):" -ForegroundColor Yellow
    foreach ($warning in $warnings) {
        Write-Host "  ! $($warning.Check): $($warning.Issue)" -ForegroundColor Yellow
        if ($VerbosePreference -eq "Continue") {
            Write-Host "    Detail: $($warning.Detail)" -ForegroundColor DarkGray
            if ($warning.Fix) {
                Write-Host "    Fix: $($warning.Fix)" -ForegroundColor Cyan
            }
        }
    }
    Write-Host ""
}

# Summary
if ($traps.Count -eq 0 -and $warnings.Count -eq 0) {
    Write-Host "✅ No common traps detected" -ForegroundColor Green
    Write-Host ""
    return $true
} elseif ($traps.Count -eq 0) {
    Write-Host "⚠️  $($warnings.Count) warning(s) - review before proceeding" -ForegroundColor Yellow
    Write-Host ""
    return $true
} else {
    Write-Host "❌ $($traps.Count) error(s) must be fixed before committing" -ForegroundColor Red
    Write-Host ""
    return $false
}
