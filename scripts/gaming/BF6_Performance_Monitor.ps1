# BF6 Gaming Performance Monitor
# Runs in background, logs performance metrics every 10 seconds

param(
    [int]$IntervalSeconds = 10,
    [string]$LogFile = "$env:USERPROFILE\bf6_performance_log.csv"
)

# Initialize log file with headers
if (-not (Test-Path $LogFile)) {
    "Timestamp,CPU_Percent,RAM_Used_GB,RAM_Available_GB,GPU_Temp,FPS_Estimate,Network_Latency_ms,Disk_Usage_Percent" | Out-File $LogFile
}

Write-Host "[BF6 MONITOR] Started - logging to $LogFile"
Write-Host "[BF6 MONITOR] Press Ctrl+C to stop"
Write-Host ""

$iteration = 0

while ($true) {
    try {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

        # CPU Usage
        $cpu = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue

        # RAM Usage
        $ram = Get-CimInstance Win32_OperatingSystem
        $ramUsedGB = [math]::Round(($ram.TotalVisibleMemorySize - $ram.FreePhysicalMemory) / 1MB, 2)
        $ramAvailGB = [math]::Round($ram.FreePhysicalMemory / 1MB, 2)

        # GPU Temperature (if NVIDIA)
        $gpuTemp = "N/A"
        try {
            $nvsmi = & "nvidia-smi" --query-gpu=temperature.gpu --format=csv,noheader,nounits 2>$null
            if ($LASTEXITCODE -eq 0) {
                $gpuTemp = $nvsmi.Trim()
            }
        } catch {
            # No NVIDIA GPU or nvidia-smi not found
        }

        # FPS Estimate (based on CPU - rough heuristic)
        $fpsEstimate = if ($cpu -lt 50) { "60+" } elseif ($cpu -lt 70) { "45-60" } elseif ($cpu -lt 85) { "30-45" } else { "<30" }

        # Network Latency (ping Cloudflare DNS)
        $latency = "N/A"
        try {
            $ping = Test-Connection -ComputerName 1.1.1.1 -Count 1 -ErrorAction SilentlyContinue
            if ($ping) {
                $latency = $ping.ResponseTime
            }
        } catch {
            # Network unavailable
        }

        # Disk Usage
        $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
        $diskPercent = [math]::Round((($disk.Size - $disk.FreeSpace) / $disk.Size) * 100, 1)

        # Log to CSV
        "$timestamp,$cpu,$ramUsedGB,$ramAvailGB,$gpuTemp,$fpsEstimate,$latency,$diskPercent" | Out-File $LogFile -Append

        # Console output (every 3rd iteration to reduce spam)
        if ($iteration % 3 -eq 0) {
            Write-Host "[$timestamp] CPU: $($cpu.ToString('0.0'))% | RAM: $ramUsedGB GB | GPU: ${gpuTemp}°C | FPS: $fpsEstimate | Ping: ${latency}ms"
        }

        $iteration++

        Start-Sleep -Seconds $IntervalSeconds
    }
    catch {
        Write-Host "[ERROR] Monitoring iteration failed: $_"
        Start-Sleep -Seconds $IntervalSeconds
    }
}
