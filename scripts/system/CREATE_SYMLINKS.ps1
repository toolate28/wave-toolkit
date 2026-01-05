# SpiralSafe Ecosystem - Windows Symlinks Creation Script
# Run as Administrator

param(
    [switch]$Force
)

Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   SPIRALSAFE ECOSYSTEM - SYMLINK CREATION" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "❌ ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Right-click PowerShell and select 'Run as Administrator'" -ForegroundColor Yellow
    Write-Host "Then run: C:\Users\iamto\CREATE_SYMLINKS.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Running as Administrator" -ForegroundColor Green
Write-Host ""

# Define symlinks
$symlinks = @(
    @{
        Path = "C:\SpiralSafe"
        Target = "C:\Users\iamto\SpiralSafe-FromGitHub"
        Description = "SpiralSafe Main (Bridges)"
    },
    @{
        Path = "C:\Repos"
        Target = "C:\Users\iamto\repos"
        Description = "All Repositories"
    },
    @{
        Path = "C:\Quantum"
        Target = "C:\Users\iamto\quantum-redstone"
        Description = "Quantum-Redstone Framework"
    },
    @{
        Path = "C:\ClaudeNPC"
        Target = "C:\Users\iamto\repos\ClaudeNPC-Server-Suite"
        Description = "ClaudeNPC Server Suite"
    }
)

# Create symlinks
Write-Host "📁 Creating Symlinks..." -ForegroundColor Cyan
Write-Host ""

foreach ($link in $symlinks) {
    $exists = Test-Path $link.Path

    if ($exists) {
        if ($Force) {
            Write-Host "  ⚠️  Removing existing: $($link.Path)" -ForegroundColor Yellow
            Remove-Item $link.Path -Force -Recurse
        } else {
            Write-Host "  ⚠️  Already exists: $($link.Path)" -ForegroundColor Yellow
            Write-Host "      Use -Force to recreate" -ForegroundColor DarkGray
            continue
        }
    }

    if (Test-Path $link.Target) {
        try {
            New-Item -ItemType SymbolicLink -Path $link.Path -Target $link.Target | Out-Null
            Write-Host "  ✅ Created: $($link.Path)" -ForegroundColor Green
            Write-Host "     → $($link.Target)" -ForegroundColor DarkGray
            Write-Host "     ($($link.Description))" -ForegroundColor DarkGray
        } catch {
            Write-Host "  ❌ Failed: $($link.Path)" -ForegroundColor Red
            Write-Host "     Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    } else {
        Write-Host "  ❌ Target not found: $($link.Target)" -ForegroundColor Red
    }

    Write-Host ""
}

# Create Desktop Shortcuts
Write-Host "🖥️  Creating Desktop Shortcuts..." -ForegroundColor Cyan
Write-Host ""

$WshShell = New-Object -comObject WScript.Shell
$Desktop = [System.Environment]::GetFolderPath('Desktop')

# mcstart Dashboard Shortcut
$ShortcutPath = "$Desktop\SpiralSafe Dashboard.lnk"
if (Test-Path $ShortcutPath) {
    if ($Force) {
        Remove-Item $ShortcutPath -Force
    } else {
        Write-Host "  ⚠️  Dashboard shortcut already exists" -ForegroundColor Yellow
        $ShortcutPath = $null
    }
}

if ($ShortcutPath) {
    $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
    $Shortcut.TargetPath = "powershell.exe"
    $Shortcut.Arguments = "-ExecutionPolicy Bypass -NoExit -File C:\Users\iamto\mcstart.ps1"
    $Shortcut.WorkingDirectory = "C:\Users\iamto"
    $Shortcut.IconLocation = "C:\Windows\System32\shell32.dll,21"
    $Shortcut.Description = "SpiralSafe + ClaudeNPC Control Dashboard"
    $Shortcut.Save()
    Write-Host "  ✅ Created: SpiralSafe Dashboard.lnk" -ForegroundColor Green
}

# Prism Launcher Shortcut
$PrismExe = "C:\Users\iamto\AppData\Local\Programs\PrismLauncher\prismlauncher.exe"
if (Test-Path $PrismExe) {
    $ShortcutPath = "$Desktop\Prism Launcher.lnk"
    if ((Test-Path $ShortcutPath) -and -not $Force) {
        Write-Host "  ⚠️  Prism Launcher shortcut already exists" -ForegroundColor Yellow
    } else {
        if (Test-Path $ShortcutPath) { Remove-Item $ShortcutPath -Force }

        $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
        $Shortcut.TargetPath = $PrismExe
        $Shortcut.WorkingDirectory = "C:\Users\iamto\AppData\Roaming\PrismLauncher"
        $Shortcut.Description = "Prism Launcher - Minecraft"
        $Shortcut.Save()
        Write-Host "  ✅ Created: Prism Launcher.lnk" -ForegroundColor Green
    }
}

Write-Host ""

# Create E: Drive Structure
Write-Host "💾 Creating E: Drive Optimization Structure..." -ForegroundColor Cyan
Write-Host ""

$eDriveStructure = @(
    "E:\SpiralSafe",
    "E:\SpiralSafe\atom-trails",
    "E:\SpiralSafe\docker-volumes",
    "E:\SpiralSafe\docker-volumes\hologram",
    "E:\SpiralSafe\docker-volumes\tartarus",
    "E:\SpiralSafe\minecraft-servers",
    "E:\Python-Envs",
    "E:\Build-Cache",
    "E:\Build-Cache\maven",
    "E:\Build-Cache\npm"
)

foreach ($dir in $eDriveStructure) {
    if (Test-Path $dir) {
        Write-Host "  ✅ Exists: $dir" -ForegroundColor Green
    } else {
        try {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            Write-Host "  ✅ Created: $dir" -ForegroundColor Green
        } catch {
            Write-Host "  ❌ Failed: $dir" -ForegroundColor Red
            Write-Host "     Error: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

Write-Host ""

# Summary
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "   SUMMARY" -ForegroundColor Cyan
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host ""
Write-Host "✅ Symlinks Created:" -ForegroundColor Green
Write-Host "   C:\SpiralSafe    → SpiralSafe-FromGitHub (Bridges)"
Write-Host "   C:\Repos         → repos (All projects)"
Write-Host "   C:\Quantum       → quantum-redstone (Circuits)"
Write-Host "   C:\ClaudeNPC     → ClaudeNPC-Server-Suite (Plugin)"
Write-Host ""
Write-Host "✅ Desktop Shortcuts:" -ForegroundColor Green
Write-Host "   SpiralSafe Dashboard.lnk (mcstart.ps1)"
Write-Host "   Prism Launcher.lnk"
Write-Host ""
Write-Host "✅ E: Drive Structure:" -ForegroundColor Green
Write-Host "   E:\SpiralSafe\atom-trails"
Write-Host "   E:\SpiralSafe\docker-volumes"
Write-Host "   E:\SpiralSafe\minecraft-servers"
Write-Host "   E:\Python-Envs"
Write-Host "   E:\Build-Cache"
Write-Host ""
Write-Host "📝 Next Steps:" -ForegroundColor Yellow
Write-Host "   1. Update docker-compose.yml to use E:\SpiralSafe\atom-trails"
Write-Host "   2. Update ClaudeNPC config to use E:\SpiralSafe\atom-trails"
Write-Host "   3. Set MAVEN_OPTS=-Dmaven.repo.local=E:\Build-Cache\maven"
Write-Host "   4. Run dashboard: C:\SpiralSafe Dashboard.lnk"
Write-Host ""
Write-Host "The Evenstar Guides Us ✦" -ForegroundColor Cyan
