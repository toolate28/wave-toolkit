# MASTER CONTROL DASHBOARD
function Show-Dashboard {
    Clear-Host
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host "   MASTER CONTROL DASHBOARD" -ForegroundColor Yellow
    Write-Host "=====================================" -ForegroundColor Cyan
    Write-Host ""

    # System Status
    Get-SystemStatus

    Write-Host "`n=== SERVICES ===" -ForegroundColor Cyan
    $cfTunnel = Get-Process cloudflared -ErrorAction SilentlyContinue
    Write-Host "Cloudflare Tunnel: " -NoNewline
    if ($cfTunnel) { Write-Host "RUNNING" -ForegroundColor Green } else { Write-Host "STOPPED" -ForegroundColor Red }

    Write-Host "`n=== QUICK ACTIONS ===" -ForegroundColor Cyan
    Write-Host "[1] Deploy SpiralSafe to Cloudflare"
    Write-Host "[2] Start Cloudflare Tunnel"
    Write-Host "[3] Start Logdy"
    Write-Host "[4] Optimize for Gaming"
    Write-Host "[5] Clean System Memory"
    Write-Host "[6] System Status"
    Write-Host "[Q] Quit"
    Write-Host ""

    $choice = Read-Host "Select action"
    switch ($choice) {
        "1" { Deploy-SpiralSafe }
        "2" { Start-CloudflareTunnel }
        "3" { Start-Logdy }
        "4" { & "$env:USERPROFILE\Optimize-Gaming.ps1" }
        "5" { Clear-Memory; Write-Host "Memory cleared" -ForegroundColor Green }
        "6" { Get-SystemStatus }
        "Q" { return }
    }

    if ($choice -ne "Q") {
        Read-Host "`nPress Enter to continue"
        Show-Dashboard
    }
}

# Auto-show dashboard
Show-Dashboard
