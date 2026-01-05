# Wave.Logging.psm1
# Centralized logging tools for SpiralSafe / ClaudeNPC / Quantum

param()

function New-WaveLogRecord {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Timestamp,
        [Parameter(Mandatory)][string]$Level,
        [Parameter(Mandatory)][string]$Source,
        [Parameter(Mandatory)][string]$Repo,
        [Parameter(Mandatory)][string]$File,
        [Parameter(Mandatory)][string]$Line,
        [Parameter(Mandatory)][string]$Message,
        [int]$MaxMessageLength = 200
    )

    $msg = $Message.Trim()
    $len = $msg.Length
    if ($len -gt $MaxMessageLength) {
        $msg = $msg.Substring(0, $MaxMessageLength) + "…"
    }

    $msgClean = $msg -replace "`t"," " -replace "`r"," " -replace "`n"," "

    $cols = @(
        $Timestamp,
        $Level,
        $Source,
        $Repo,
        $File,
        $Line,
        $msgClean,
        $len
    )

    ($cols -join "`t")
}

function Get-WaveLogFiles {
    [CmdletBinding()]
    param()

    $home = $HOME
    $files = @()

    # 1) System / gaming logs
    $bf6 = Join-Path $home "bf6_performance_log.csv"
    if (Test-Path $bf6) {
        $files += [pscustomobject]@{
            Path   = $bf6
            Source = 'system'
            Repo   = 'gaming'
            Kind   = 'csv'
        }
    }

    # 2) SpiralSafe bridges logs
    $bridgeDir = Join-Path $home "SpiralSafe-FromGitHub\bridges"
    if (Test-Path $bridgeDir) {
        Get-ChildItem $bridgeDir -Filter "*.log" -Recurse | ForEach-Object {
            $files += [pscustomobject]@{
                Path   = $_.FullName
                Source = 'spiralsafe'
                Repo   = 'SpiralSafe'
                Kind   = 'text'
            }
        }
    }

    # 3) Quantum-redstone logs
    $qrDir = Join-Path $home "quantum-redstone"
    if (Test-Path $qrDir) {
        Get-ChildItem $qrDir -Filter "*.log" -Recurse | ForEach-Object {
            $files += [pscustomobject]@{
                Path   = $_.FullName
                Source = 'quantum'
                Repo   = 'quantum-redstone'
                Kind   = 'text'
            }
        }
    }

    # 4) ClaudeNPC logs
    $cnDir = Join-Path $home "repos\ClaudeNPC-Server-Suite"
    if (Test-Path $cnDir) {
        Get-ChildItem $cnDir -Filter "*.log" -Recurse | ForEach-Object {
            $files += [pscustomobject]@{
                Path   = $_.FullName
                Source = 'claudenpc'
                Repo   = 'ClaudeNPC-Server-Suite'
                Kind   = 'text'
            }
        }
    }

    # 5) ATOM trail
    $atomTrail = Join-Path $home ".atom-trail"
    if (Test-Path $atomTrail) {
        $files += [pscustomobject]@{
            Path   = $atomTrail
            Source = 'spiralsafe'
            Repo   = 'SpiralSafe'
            Kind   = 'text'
        }
    }

    return $files
}

function Collect-SpiralLogs {
    [CmdletBinding()]
    param(
        [string]$OutputDir = "$HOME\.logdy\streams",
        [int]$MaxMessageLength = 200
    )

    if (!(Test-Path $OutputDir)) {
        New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null
    }

    $aggregatePath = Join-Path $OutputDir "spiralsafe_aggregate.tsv"
    $now = (Get-Date).ToString("o")
    $records = @()

    $files = Get-WaveLogFiles

    foreach ($f in $files) {
        $path   = $f.Path
        $source = $f.Source
        $repo   = $f.Repo
        $kind   = $f.Kind
        $name   = [System.IO.Path]::GetFileName($path)

        if ($kind -eq 'csv') {
            $lineNo = 0
            Import-Csv $path | ForEach-Object {
                $lineNo++
                $ts = $_.Timestamp
                if (-not $ts) { $ts = $now }
                $msg = ($_ | ConvertTo-Json -Compress)
                $records += New-WaveLogRecord -Timestamp $ts -Level 'INFO' `
                    -Source $source -Repo $repo -File $name -Line $lineNo `
                    -Message $msg -MaxMessageLength $MaxMessageLength
            }
        } else {
            $lineNo = 0
            Get-Content $path | ForEach-Object {
                $lineNo++
                $records += New-WaveLogRecord -Timestamp $now -Level 'INFO' `
                    -Source $source -Repo $repo -File $name -Line $lineNo `
                    -Message $_ -MaxMessageLength $MaxMessageLength
            }
        }
    }

    if ($records.Count -gt 0) {
        $records | Out-File $aggregatePath -Encoding UTF8 -Append
        Write-Host "✅ Wrote $($records.Count) records to $aggregatePath"
    } else {
        Write-Host "ℹ️  No logs collected (no matching files found)." -ForegroundColor Yellow
    }
}

function Test-CollectSpiralLogs {
    [CmdletBinding()]
    param()

    $tmpDir = Join-Path $env:TEMP "logdy-test-$(Get-Random)"
    New-Item -ItemType Directory -Force -Path $tmpDir | Out-Null

    Collect-SpiralLogs -OutputDir $tmpDir -MaxMessageLength 80

    $outFile = Join-Path $tmpDir "spiralsafe_aggregate.tsv"
    if (-not (Test-Path $outFile)) {
        Write-Host "❌ Test failed: no output file created" -ForegroundColor Red
        return $false
    }

    $lines = Get-Content $outFile
    if ($lines.Count -eq 0) {
        Write-Host "⚠️  Test completed: file exists but no lines (no logs matched)." -ForegroundColor Yellow
        return $true
    }

    $first = $lines[0] -split "`t"
    if ($first.Count -ne 8) {
        Write-Host "❌ Test failed: expected 8 TSV columns, got $($first.Count)" -ForegroundColor Red
        return $false
    }

    Write-Host "✅ Test-CollectSpiralLogs passed" -ForegroundColor Green
    return $true
}

Export-ModuleMember -Function Collect-SpiralLogs, Test-CollectSpiralLogs