# Setup-Wave.ps1
# One-time bootstrap - run this first, then you're ready to go

Write-Host "`n=== Wave + Claude Setup ===" -ForegroundColor Cyan
Write-Host "Setting up directories and testing environment detection...`n"

# Create directory structure
$dirs = @(
    ".claude",
    ".claude\prompts",
    ".claude\logs",
    ".claude\logs\sessions"
)

foreach ($dir in $dirs) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Host "  Created: $dir" -ForegroundColor Green
    } else {
        Write-Host "  Exists:  $dir" -ForegroundColor DarkGray
    }
}

# Test context capture
Write-Host "`nTesting environment detection..." -ForegroundColor Yellow
& "$PSScriptRoot\Get-WaveContext.ps1"

# Generate initial system prompt
Write-Host "`nGenerating initial system prompt..." -ForegroundColor Yellow
& "$PSScriptRoot\New-ClaudeSystemPrompt.ps1"

# Show what was created
Write-Host "`n=== Setup Complete ===" -ForegroundColor Green
Write-Host @"

Files created:
  wave.md                    - The guide (read this)
  Get-WaveContext.ps1        - Captures your environment
  New-ClaudeSystemPrompt.ps1 - Generates Claude system prompt
  Invoke-ClaudeSession.ps1   - Full session workflow
  Setup-Wave.ps1             - This script (run once)

  .claude\wave_context.json        - Your environment snapshot
  .claude\prompts\wave-system.md   - Generated system prompt

Quick start:
  .\Get-WaveContext.ps1                              # Capture context
  .\Invoke-ClaudeSession.ps1 -Task "your task here"  # Full session

Read wave.md for the philosophy and details.

Welcome to the flow.
"@
