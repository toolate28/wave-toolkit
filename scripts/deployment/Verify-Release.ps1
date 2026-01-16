<#
.SYNOPSIS
    Verify wave-toolkit release integrity.

.DESCRIPTION
    This script downloads and verifies wave-toolkit release artifacts:
    1. Downloads release checksums and signatures from GitHub
    2. Imports the SpiralSafe signing key (if not already imported)
    3. Verifies GPG signature on checksums (if available and gpg is installed)
    4. Downloads the release archive
    5. Verifies the archive checksum

.PARAMETER Version
    The release version to verify (e.g., "1.0.1")

.EXAMPLE
    .\Verify-Release.ps1 -Version "1.0.1"

.NOTES
    Requires: curl or Invoke-WebRequest
    Optional: gpg (for signature verification)
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Version
)

$ErrorActionPreference = 'Stop'

$Repo = "toolate28/wave-toolkit"
$KeyUrl = "https://raw.githubusercontent.com/$Repo/main/.well-known/pgp-key.txt"
$BaseUrl = "https://github.com/$Repo/releases/download/v$Version"

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "[WARN] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Test-CommandAvailable {
    param([string]$Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

function Get-FileHash256 {
    param([string]$Path)
    (Get-FileHash -Path $Path -Algorithm SHA256).Hash.ToLower()
}

# Create temp directory
$TempDir = Join-Path $env:TEMP "wave-verify-$([Guid]::NewGuid().ToString('N').Substring(0,8))"
New-Item -ItemType Directory -Path $TempDir -Force | Out-Null

try {
    Push-Location $TempDir

    Write-Info "Verifying wave-toolkit v$Version"
    Write-Info "Working directory: $TempDir"

    # Download checksums
    Write-Info "Downloading release artifacts..."
    $ChecksumFile = "SHA256SUMS.txt"
    $ChecksumUrl = "$BaseUrl/$ChecksumFile"
    
    try {
        Invoke-WebRequest -Uri $ChecksumUrl -OutFile $ChecksumFile -ErrorAction Stop
        Write-Info "Downloaded checksums"
    }
    catch {
        Write-Error "Could not download SHA256SUMS.txt"
        Write-Error "Release v$Version may not exist or may not have checksums"
        exit 1
    }

    # Try to download signature
    $HasSignature = $false
    $SignatureFile = "SHA256SUMS.txt.asc"
    $SignatureUrl = "$BaseUrl/$SignatureFile"
    
    try {
        Invoke-WebRequest -Uri $SignatureUrl -OutFile $SignatureFile -ErrorAction Stop
        $HasSignature = $true
        Write-Info "Found GPG signature"
    }
    catch {
        Write-Warn "No GPG signature found for this release"
    }

    # Verify GPG signature if available and gpg is installed
    if ($HasSignature -and (Test-CommandAvailable "gpg")) {
        Write-Info "Importing SpiralSafe signing key..."
        try {
            $keyContent = Invoke-WebRequest -Uri $KeyUrl -ErrorAction Stop
            $keyContent.Content | gpg --import 2>$null
            Write-Info "Signing key imported"
        }
        catch {
            Write-Warn "Could not import signing key (may already be imported or not available)"
        }

        Write-Info "Verifying GPG signature..."
        $gpgResult = gpg --verify $SignatureFile $ChecksumFile 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Info "GPG signature verified successfully"
        }
        else {
            Write-Error "GPG signature verification failed!"
            Write-Host $gpgResult
            exit 1
        }
    }
    elseif ($HasSignature) {
        Write-Warn "gpg not found - skipping signature verification"
        Write-Warn "Install GnuPG to verify signatures"
    }

    # Download and verify archive
    $ArchiveFile = "wave-toolkit-$Version.zip"
    $ArchiveUrl = "$BaseUrl/$ArchiveFile"

    Write-Info "Downloading release archive..."
    try {
        Invoke-WebRequest -Uri $ArchiveUrl -OutFile $ArchiveFile -ErrorAction Stop
    }
    catch {
        Write-Error "Could not download release archive"
        exit 1
    }

    # Parse expected checksum from file
    $ChecksumContent = Get-Content $ChecksumFile
    $ExpectedLine = $ChecksumContent | Where-Object { $_ -match [regex]::Escape($ArchiveFile) }
    
    if (-not $ExpectedLine) {
        Write-Warn "Could not find archive checksum in SHA256SUMS.txt"
        Write-Info "Computing local checksum for reference..."
        $LocalHash = Get-FileHash256 -Path $ArchiveFile
        Write-Host "SHA256: $LocalHash"
        exit 0
    }

    # Extract expected hash (format: "hash  filename" with two spaces)
    $ExpectedHash = ($ExpectedLine -split '\s+')[0].ToLower()
    $ActualHash = Get-FileHash256 -Path $ArchiveFile

    Write-Info "Verifying archive checksum..."
    
    if ($ExpectedHash -eq $ActualHash) {
        Write-Info "Archive checksum verified successfully"
        Write-Host ""
        Write-Host "✅ Release v$Version verified successfully!" -ForegroundColor Green
        
        if ($HasSignature -and (Test-CommandAvailable "gpg")) {
            Write-Host "   - GPG signature: VALID" -ForegroundColor Green
        }
        elseif ($HasSignature) {
            Write-Host "   - GPG signature: AVAILABLE (gpg not installed)" -ForegroundColor Yellow
        }
        else {
            Write-Host "   - GPG signature: NOT AVAILABLE" -ForegroundColor Yellow
        }
        
        Write-Host "   - SHA-256 checksum: VALID" -ForegroundColor Green
    }
    else {
        Write-Error "Archive checksum mismatch!"
        Write-Error "Expected: $ExpectedHash"
        Write-Error "Actual:   $ActualHash"
        exit 1
    }
}
finally {
    Pop-Location
    # Cleanup temp directory
    if (Test-Path $TempDir) {
        Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
