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
