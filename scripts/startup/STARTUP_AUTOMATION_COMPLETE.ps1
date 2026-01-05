# COMPLETE STARTUP AUTOMATION
# Ensures all services start on boot

Write-Host "=== STARTUP AUTOMATION SETUP ===" -ForegroundColor Cyan

# Create Windows Task Scheduler tasks for services that need to run on startup

# 1. Cloudflare Tunnel Auto-Start (Already created via startup folder)
Write-Host "[1/4] Cloudflare Tunnel - Already configured in Startup folder" -ForegroundColor Green

# 2. Create scheduled task for system optimization on startup
Write-Host "[2/4] Creating System Optimization scheduled task..." -ForegroundColor Green

$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$env:USERPROFILE\Optimize-Gaming.ps1`""
$trigger = New-ScheduledTaskTrigger -AtStartup
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable

try {
    Register-ScheduledTask -TaskName "SystemOptimizationOnStartup" -Action $action -Trigger $trigger -Principal $principal -Settings $settings -Force | Out-Null
    Write-Host "  Task created: SystemOptimizationOnStartup" -ForegroundColor Gray
} catch {
    Write-Host "  Warning: Could not create scheduled task (may need admin)" -ForegroundColor Yellow
}

# 3. Create auto-updater for Cloudflare deployments
Write-Host "[3/4] Creating deployment auto-updater..." -ForegroundColor Green

$updateScript = @'
# Auto-update SpiralSafe deployments
$logFile = "$env:TEMP\spiralsafe-autoupdate.log"
Start-Transcript -Path $logFile -Append

try {
    Set-Location C:\Users\iamto\SpiralSafe-FromGitHub

    # Pull latest from Git
    git fetch origin
    $behind = git rev-list HEAD..origin/main --count

    if ($behind -gt 0) {
        Write-Host "Updating SpiralSafe repository..."
        git pull --rebase

        # Rebuild and redeploy if configured
        if (Test-Path "cloudflare-workers-deployment\worker-built.js") {
            Set-Location cloudflare-workers-deployment
            python build.py
            # Uncomment when account_id is configured:
            # wrangler deploy --env production
        }
    } else {
        Write-Host "SpiralSafe is up to date"
    }
} catch {
    Write-Host "Auto-update failed: $_"
}

Stop-Transcript
'@

$updateScript | Out-File "$env:USERPROFILE\AutoUpdate-SpiralSafe.ps1" -Encoding UTF8 -Force

# Create scheduled task for daily updates
$updateAction = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$env:USERPROFILE\AutoUpdate-SpiralSafe.ps1`""
$updateTrigger = New-ScheduledTaskTrigger -Daily -At 3am
try {
    Register-ScheduledTask -TaskName "SpiralSafeAutoUpdate" -Action $updateAction -Trigger $updateTrigger -Principal $principal -Settings $settings -Force | Out-Null
    Write-Host "  Task created: SpiralSafeAutoUpdate (runs daily at 3am)" -ForegroundColor Gray
} catch {
    Write-Host "  Warning: Could not create update task" -ForegroundColor Yellow
}

# 4. Create comprehensive startup checklist
Write-Host "[4/4] Creating startup checklist..." -ForegroundColor Green

$checklist = @"
=== SYSTEM STARTUP CHECKLIST ===
Generated: $(Get-Date)

SERVICES CONFIGURED FOR AUTOMATIC STARTUP:
------------------------------------------
1. Cloudflare Tunnel
   Location: $env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\cloudflare-tunnel.bat
   Status: Will start automatically on login

2. System Optimization
   Task: SystemOptimizationOnStartup
   Status: Runs on system boot (if admin rights granted)

3. SpiralSafe Auto-Update
   Task: SpiralSafeAutoUpdate
   Schedule: Daily at 3:00 AM

MANUAL VERIFICATION ON STARTUP:
-------------------------------
After reboot, verify these are running:

1. Cloudflare Tunnel:
   Command: Get-Process cloudflared -ErrorAction SilentlyContinue
   Expected: Process should be running

2. Check System Status:
   Command: Get-SystemStatus
   (Available after PowerShell profile loads)

3. Verify Cloudflare Deployments:
   Workers: Run 'wrangler deployments list'
   Pages: Check Cloudflare Dashboard
   Tunnel: Run 'cloudflared tunnel list'

QUICK ACCESS COMMANDS:
----------------------
- Dashboard: Run 'powershell -File $env:USERPROFILE\Dashboard.ps1'
- Deploy SpiralSafe: Run 'Deploy-SpiralSafe' in PowerShell
- Start Tunnel: Run 'Start-CloudflareTunnel' in PowerShell
- Game Optimization: Run Desktop\Launch_BF2042_Optimized.bat
- System Status: Run 'Get-SystemStatus' in PowerShell

FILES LOCATIONS:
----------------
- Master Dashboard: $env:USERPROFILE\Dashboard.ps1
- PowerShell Profile: $env:USERPROFILE\OneDrive\Documents\WindowsPowerShell\profile.ps1
- BF2042 Config: $env:USERPROFILE\BF2042_OPTIMIZED_CONFIG.txt
- SpiralSafe Deployment: C:\Users\iamto\SpiralSafe-FromGitHub\cloudflare-workers-deployment
- Deployment Guide: C:\Users\iamto\SpiralSafe-FromGitHub\cloudflare-workers-deployment\DEPLOYMENT_GUIDE.md

NEXT STEPS TO COMPLETE DEPLOYMENT:
-----------------------------------
1. Get your Cloudflare Account ID:
   wrangler whoami

2. Edit wrangler.toml:
   File: C:\Users\iamto\SpiralSafe-FromGitHub\cloudflare-workers-deployment\wrangler.toml
   Add: account_id = "YOUR_ACCOUNT_ID_HERE"

3. Deploy Workers:
   cd C:\Users\iamto\SpiralSafe-FromGitHub\cloudflare-workers-deployment
   wrangler deploy

4. Deploy Pages:
   cd C:\Users\iamto\SpiralSafe-FromGitHub\SpiralSafe
   wrangler pages deploy . --project-name=spiralsafe-pages

5. Create Cloudflare Tunnel (if not exists):
   cloudflared tunnel create spiralsafe-tunnel
   cloudflared tunnel run spiralsafe-tunnel

6. Apply Battlefield 6 Settings:
   - Open: $env:USERPROFILE\BF2042_OPTIMIZED_CONFIG.txt
   - Apply Steam launch options
   - Configure in-game settings
   - Set NVIDIA Control Panel (if applicable)

RESTART REQUIRED:
-----------------
Restart your PC to activate all optimizations!

=== Hope && Sauce - Infrastructure that compounds ===
"@

$checklist | Out-File "$env:USERPROFILE\STARTUP_CHECKLIST.txt" -Encoding UTF8 -Force
$checklist | Out-File "$env:USERPROFILE\Desktop\STARTUP_CHECKLIST.txt" -Encoding UTF8 -Force
Write-Host "  Checklist created on Desktop" -ForegroundColor Gray

# Summary
Write-Host "`n=== STARTUP AUTOMATION COMPLETE ===" -ForegroundColor Green
Write-Host "`nConfigured:" -ForegroundColor Yellow
Write-Host "  - Cloudflare Tunnel auto-start"
Write-Host "  - System optimization on boot"
Write-Host "  - Daily auto-updates for SpiralSafe"
Write-Host "  - Startup checklist on Desktop"
Write-Host "`nFiles created:" -ForegroundColor Yellow
Write-Host "  - $env:USERPROFILE\AutoUpdate-SpiralSafe.ps1"
Write-Host "  - Desktop\STARTUP_CHECKLIST.txt"
Write-Host "`nView checklist: notepad Desktop\STARTUP_CHECKLIST.txt" -ForegroundColor Cyan
Write-Host "RESTART NOW for full effect!" -ForegroundColor Red
