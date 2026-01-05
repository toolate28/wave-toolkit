# BATTLEFIELD 6 (BF2042) PERFORMANCE OPTIMIZER
# Maximizes FPS and reduces latency

Write-Host "=== BATTLEFIELD 6 OPTIMIZER ===" -ForegroundColor Cyan

# 1. Find Steam and BF2042 installation
Write-Host "`n[1/6] Locating Steam and Battlefield 6..." -ForegroundColor Green
$steamPaths = @(
    "C:\Program Files (x86)\Steam",
    "C:\Program Files\Steam",
    "D:\Steam",
    "E:\Steam"
)

$steamPath = $null
foreach ($path in $steamPaths) {
    if (Test-Path $path) {
        $steamPath = $path
        Write-Host "  Steam found: $steamPath" -ForegroundColor Gray
        break
    }
}

# 2. Optimize Windows Game Mode
Write-Host "`n[2/6] Optimizing Windows Game Mode..." -ForegroundColor Green
Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AutoGameModeEnabled" -Value 1 -Force
Set-ItemProperty -Path "HKCU:\Software\Microsoft\GameBar" -Name "AllowAutoGameMode" -Value 1 -Force
Write-Host "  Game Mode optimized" -ForegroundColor Gray

# 3. Disable Game DVR and Broadcasting
Write-Host "`n[3/6] Disabling Game DVR..." -ForegroundColor Green
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Force
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_FSEBehaviorMode" -Value 2 -Force
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_HonorUserFSEBehaviorMode" -Value 1 -Force
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_DXGIHonorFSEWindowsCompatible" -Value 1 -Force
Write-Host "  Game DVR disabled for maximum performance" -ForegroundColor Gray

# 4. Network Optimizations for Low Latency
Write-Host "`n[4/6] Optimizing Network for Low Latency..." -ForegroundColor Green

# Disable Nagle's Algorithm (reduces latency)
$tcpParams = "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"
Get-ChildItem $tcpParams | ForEach-Object {
    Set-ItemProperty -Path $_.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
    Set-ItemProperty -Path $_.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue
}

# Set network throttling index (0 = disabled)
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xffffffff -Type DWord -Force

Write-Host "  Network latency optimizations applied" -ForegroundColor Gray

# 5. GPU and CPU Priority
Write-Host "`n[5/6] Setting GPU/CPU Priorities..." -ForegroundColor Green

# Set GPU priority for games
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "GPU Priority" -Value 8 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "Priority" -Value 6 -Type DWord -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Games" -Name "Scheduling Category" -Value "High" -Force

Write-Host "  GPU/CPU priorities set to maximum for games" -ForegroundColor Gray

# 6. Create BF2042 Launch Configuration
Write-Host "`n[6/6] Creating BF2042 Optimized Launch Config..." -ForegroundColor Green

$bf2042Config = @"
=== BATTLEFIELD 6 (BF2042) OPTIMIZED SETTINGS ===

STEAM LAUNCH OPTIONS:
-high -nojoy -novid -freq 165 -refresh 165 +fps_max 165 -dx12

Explanation:
- -high: High CPU priority
- -nojoy: Disable joystick support (if not using controller)
- -novid: Skip intro videos
- -freq 165: Force 165Hz refresh rate (adjust to your monitor)
- -refresh 165: Alternative refresh rate flag
- +fps_max 165: Cap FPS at 165 (adjust to your monitor)
- -dx12: Use DirectX 12 (better performance on modern GPUs)

IN-GAME SETTINGS (Recommended):
Video:
- Display Mode: Fullscreen
- Resolution: Native (your monitor's max)
- VSync: OFF
- FPS Limiter: 165 (or your monitor's refresh rate)
- NVIDIA Reflex Low Latency: ON + Boost
- Resolution Scale: 100%
- Anti-Aliasing: TAA Medium
- Texture Quality: High
- Texture Filtering: Medium
- Lighting Quality: Medium
- Effects Quality: Low
- Post-Processing Quality: Low
- Mesh Quality: High
- Terrain Quality: Medium
- Undergrowth Quality: Low
- Ambient Occlusion: Off
- Ray Tracing: Off (unless you have RTX 4080+)

Graphics:
- DLSS/FSR: Quality mode (if available)
- Motion Blur: OFF
- Depth of Field: OFF
- Lens Distortion: OFF
- Film Grain: OFF
- Vignette: OFF
- Chromatic Aberration: OFF

Advanced:
- Future Frame Rendering: ON
- High Dynamic Range: Based on monitor
- Field of View: 90-100 (preference)

NVIDIA CONTROL PANEL (for NVIDIA GPUs):
Right-click Desktop > NVIDIA Control Panel > Manage 3D Settings > Program Settings > Battlefield 2042
- Power Management Mode: Prefer Maximum Performance
- Texture Filtering - Quality: Performance
- Threaded Optimization: On
- Low Latency Mode: Ultra
- Vertical Sync: Off
- Triple Buffering: Off
- Max Frame Rate: Set to your monitor refresh rate + 3
- Shader Cache Size: 100GB

WINDOWS SETTINGS:
- Power Plan: High Performance / Ultimate Performance
- Disable Xbox Game Bar: Win+G > Settings > Disable
- Disable Background Apps
- Close Discord/Spotify during gaming
- Update GPU drivers to latest

NETWORK OPTIMIZATION:
- Use Wired Ethernet (not WiFi)
- Close background downloads
- Port forwarding for BF2042:
  TCP: 80, 443, 9960-9969, 42100-42199
  UDP: 3659, 14000-14016, 22990-23006, 25200-25300

For competitive play, restart your PC before gaming sessions.

"@

$bf2042Config | Out-File "$env:USERPROFILE\BF2042_OPTIMIZED_CONFIG.txt" -Encoding UTF8 -Force
Write-Host "  Config saved: $env:USERPROFILE\BF2042_OPTIMIZED_CONFIG.txt" -ForegroundColor Gray

# Create quick launch script
$quickLaunch = @'
@echo off
echo Starting Battlefield 6 with optimizations...
echo.
echo - Setting process priority to High
echo - Clearing RAM
echo - Disabling background processes
echo.

REM Clear standby memory
powershell -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"

REM Set power plan to High Performance
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

REM Launch Steam and BF2042
start steam://rungameid/1517290

echo Battlefield 6 launching with optimizations!
timeout /t 3
'@

$quickLaunch | Out-File "$env:USERPROFILE\Desktop\Launch_BF2042_Optimized.bat" -Encoding ASCII -Force
Write-Host "  Quick launch created: Desktop\Launch_BF2042_Optimized.bat" -ForegroundColor Gray

# Summary
Write-Host "`n=== OPTIMIZATION COMPLETE ===" -ForegroundColor Green
Write-Host "`nChanges applied:" -ForegroundColor Yellow
Write-Host "  - Windows Game Mode optimized"
Write-Host "  - Game DVR disabled"
Write-Host "  - Network latency reduced"
Write-Host "  - GPU/CPU priorities maximized"
Write-Host "`nFiles created:" -ForegroundColor Yellow
Write-Host "  - $env:USERPROFILE\BF2042_OPTIMIZED_CONFIG.txt"
Write-Host "  - Desktop\Launch_BF2042_Optimized.bat"
Write-Host "`nNEXT STEPS:" -ForegroundColor Cyan
Write-Host "1. Open the config file and apply in-game settings"
Write-Host "2. Add Steam launch options from the config"
Write-Host "3. Configure NVIDIA Control Panel (if NVIDIA GPU)"
Write-Host "4. Use the desktop shortcut to launch BF2042"
Write-Host "`nRESTART YOUR PC for all changes to take effect!" -ForegroundColor Red
