# Invoke-ClaudeSession.ps1
# Complete session workflow - captures context, generates prompt, calls Claude

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

# Call Claude - using claude CLI
# If this doesn't work, adjust to match your CLI setup
$response = $fullPrompt | claude chat --model $Model 2>&1

# Append response to log
$response | Out-File $logFile -Append -Encoding UTF8

Write-Host "`n=== Session Complete ===" -ForegroundColor Green
Write-Host "Log saved: $logFile"
Write-Host "`nResponse:`n" -ForegroundColor Cyan
Write-Host $response
