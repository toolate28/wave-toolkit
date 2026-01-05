# Game Performance Optimizer
Write-Host "Optimizing for gaming..." -ForegroundColor Cyan

# Set high performance power plan
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

# Disable Windows Game Bar
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\GameDVR" -Name "AppCaptureEnabled" -Value 0 -Force
Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Force

# GPU optimizations
Write-Host "Apply these in NVIDIA Control Panel:" -ForegroundColor Yellow
Write-Host "- Power Management: Prefer Maximum Performance" -ForegroundColor Gray
Write-Host "- Texture Filtering: High Performance" -ForegroundColor Gray
Write-Host "- Threaded Optimization: On" -ForegroundColor Gray

Write-Host "Done! Restart Steam for changes to take effect." -ForegroundColor Green
