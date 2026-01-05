# SpiralSafe + ClaudeNPC Dashboard
# Quick launch and status checker

param(
    [Parameter(Position=0)]
    [string]$Action = "menu"
)

# Colors
$Hope = "Cyan"
$Sauce = "Yellow"
$Success = "Green"
$Warning = "Yellow"
$Error = "Red"

function Show-Header {
    Clear-Host
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor $Hope
    Write-Host "   🎮 SPIRALSAFE + CLAUDENPC CONTROL DASHBOARD" -ForegroundColor $Hope
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor $Hope
    Write-Host "   The Evenstar Guides Us ✦" -ForegroundColor DarkGray
    Write-Host ""
}

function Show-SystemStatus {
    Write-Host "📊 SYSTEM STATUS" -ForegroundColor $Sauce
    Write-Host "─────────────────────────────────────────────────────────────" -ForegroundColor DarkGray

    # Java
    try {
        $javaVer = (java -version 2>&1)[0] -replace '"', ''
        Write-Host "  ✅ Java:        $javaVer" -ForegroundColor $Success
    } catch {
        Write-Host "  ❌ Java:        Not found" -ForegroundColor $Error
    }

    # Maven
    try {
        $mavenVer = (mvn --version 2>&1)[0]
        Write-Host "  ✅ Maven:       $mavenVer" -ForegroundColor $Success
    } catch {
        Write-Host "  ❌ Maven:       Not found" -ForegroundColor $Error
    }

    # Python
    try {
        $pythonVer = python --version 2>&1
        Write-Host "  ✅ Python:      $pythonVer" -ForegroundColor $Success
    } catch {
        Write-Host "  ❌ Python:      Not found" -ForegroundColor $Error
    }

    # Docker
    try {
        $dockerVer = docker --version 2>&1
        Write-Host "  ✅ Docker:      $dockerVer" -ForegroundColor $Success
    } catch {
        Write-Host "  ⚠️  Docker:      Not installed (optional)" -ForegroundColor $Warning
    }

    Write-Host ""
}

function Show-ProjectStatus {
    Write-Host "📦 PROJECT STATUS" -ForegroundColor $Sauce
    Write-Host "─────────────────────────────────────────────────────────────" -ForegroundColor DarkGray

    # ClaudeNPC
    $claudeJar = "$HOME\repos\ClaudeNPC-Server-Suite\ClaudeNPC\target\ClaudeNPC.jar"
    if (Test-Path $claudeJar) {
        $size = [math]::Round((Get-Item $claudeJar).Length / 1KB, 1)
        Write-Host "  ✅ ClaudeNPC:   Built (${size} KB)" -ForegroundColor $Success
    } else {
        Write-Host "  ⚠️  ClaudeNPC:   Not built (run option 1)" -ForegroundColor $Warning
    }

    # Quantum Circuits
    $quantumJson = "$HOME\quantum-redstone\quantum_circuits.json"
    if (Test-Path $quantumJson) {
        $size = [math]::Round((Get-Item $quantumJson).Length / 1KB, 1)
        Write-Host "  ✅ Quantum:     7 circuits (${size} KB)" -ForegroundColor $Success
    } else {
        Write-Host "  ⚠️  Quantum:     Not generated (run option 2)" -ForegroundColor $Warning
    }

    # Bridges
    $bridgeTests = "$HOME\SpiralSafe-FromGitHub\bridges\validate_implementation.py"
    if (Test-Path $bridgeTests) {
        Write-Host "  ✅ Bridges:     Ready (12 tests)" -ForegroundColor $Success
    } else {
        Write-Host "  ⚠️  Bridges:     Missing" -ForegroundColor $Warning
    }

    # GitHub Sync
    Push-Location "$HOME\repos\ClaudeNPC-Server-Suite"
    $gitStatus = git status --porcelain 2>&1
    if ($gitStatus.Length -eq 0) {
        Write-Host "  ✅ Git:         All repos synced" -ForegroundColor $Success
    } else {
        Write-Host "  ⚠️  Git:         Uncommitted changes" -ForegroundColor $Warning
    }
    Pop-Location

    Write-Host ""
}

function Show-DiskSpace {
    Write-Host "💾 DISK SPACE" -ForegroundColor $Sauce
    Write-Host "─────────────────────────────────────────────────────────────" -ForegroundColor DarkGray

    $drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Free -ne $null }

    foreach ($drive in $drives) {
        $freeGB = [math]::Round($drive.Free / 1GB, 1)
        $usedGB = [math]::Round($drive.Used / 1GB, 1)
        $totalGB = $freeGB + $usedGB
        $percent = [math]::Round(($usedGB / $totalGB) * 100, 0)

        $color = $Success
        if ($percent -gt 90) { $color = $Error }
        elseif ($percent -gt 75) { $color = $Warning }

        $bar = "█" * ($percent / 5) + "░" * ((100 - $percent) / 5)

        Write-Host ("  {0}: [{1}] {2}% ({3} GB / {4} GB)" -f $drive.Name, $bar, $percent, $usedGB, $totalGB) -ForegroundColor $color
    }

    Write-Host ""
}

function Show-QuickActions {
    Write-Host "🎯 QUICK ACTIONS" -ForegroundColor $Sauce
    Write-Host "─────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
    Write-Host "  1. Build ClaudeNPC plugin              (mvn package)"
    Write-Host "  2. Generate quantum circuits           (Python)"
    Write-Host "  3. Run validation tests                (12 tests)"
    Write-Host "  4. Start Docker bridges                (hologram + tartarus)"
    Write-Host "  5. Open Prism Launcher                 (Minecraft)"
    Write-Host "  6. View recent ATOM trail              (last 10 entries)"
    Write-Host "  7. Test ClaudeNPC build                (run test suite)"
    Write-Host "  8. Create Prism instance               (ClaudeNPC-Quantum)"
    Write-Host "  9. System diagnostics                  (full check)"
    Write-Host "  10. Optimize E: drive                  (move data)"
    Write-Host ""
    Write-Host "  R. Refresh dashboard"
    Write-Host "  Q. Quit"
    Write-Host ""
}

function Build-ClaudeNPC {
    Write-Host "🔨 Building ClaudeNPC plugin..." -ForegroundColor $Hope
    Push-Location "$HOME\repos\ClaudeNPC-Server-Suite\ClaudeNPC"
    mvn clean package -DskipTests
    Pop-Location
    Write-Host ""
    Write-Host "Press any key to continue..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Generate-QuantumCircuits {
    Write-Host "⚛️  Generating quantum circuits..." -ForegroundColor $Hope
    Push-Location "$HOME\quantum-redstone"
    python quantum_circuit_generator.py
    Pop-Location
    Write-Host ""
    Write-Host "Press any key to continue..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Run-ValidationTests {
    Write-Host "🧪 Running validation tests..." -ForegroundColor $Hope
    Push-Location "$HOME\SpiralSafe-FromGitHub\bridges"
    python validate_implementation.py
    Pop-Location
    Write-Host ""
    Write-Host "Press any key to continue..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Start-DockerBridges {
    Write-Host "🐋 Starting Docker bridges..." -ForegroundColor $Hope
    Push-Location "$HOME\SpiralSafe-FromGitHub\bridges"

    if (Test-Path "docker-compose.yml") {
        docker-compose up -d
        Write-Host ""
        Write-Host "Services started:" -ForegroundColor $Success
        docker-compose ps
    } else {
        Write-Host "❌ docker-compose.yml not found!" -ForegroundColor $Error
    }

    Pop-Location
    Write-Host ""
    Write-Host "Press any key to continue..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Open-PrismLauncher {
    Write-Host "🎮 Opening Prism Launcher..." -ForegroundColor $Hope
    $prismPath = "$env:LOCALAPPDATA\Programs\PrismLauncher\prismlauncher.exe"

    if (Test-Path $prismPath) {
        Start-Process $prismPath
        Write-Host "✅ Launched!" -ForegroundColor $Success
    } else {
        Write-Host "❌ Prism Launcher not found at: $prismPath" -ForegroundColor $Error
    }

    Write-Host ""
    Write-Host "Press any key to continue..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function View-ATOMTrail {
    Write-Host "📜 Recent ATOM trail entries..." -ForegroundColor $Hope
    Write-Host ""

    $atomFile = Get-ChildItem -Path "$HOME" -Filter "*.atom" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1

    if ($atomFile) {
        Write-Host "Reading: $($atomFile.FullName)" -ForegroundColor DarkGray
        Get-Content $atomFile.FullName | Select-Object -Last 10
    } else {
        Write-Host "⚠️  No ATOM trail files found" -ForegroundColor $Warning
        Write-Host "Run bridges to create ATOM entries" -ForegroundColor DarkGray
    }

    Write-Host ""
    Write-Host "Press any key to continue..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Test-ClaudeNPCBuild {
    Write-Host "🧪 Testing ClaudeNPC build..." -ForegroundColor $Hope
    Push-Location "$HOME\repos\ClaudeNPC-Server-Suite\ClaudeNPC"

    if (Test-Path "target\ClaudeNPC.jar") {
        Write-Host "✅ JAR file exists" -ForegroundColor $Success

        # Check JAR contents
        jar -tf target\ClaudeNPC.jar | Select-String "PythonBridge" | ForEach-Object {
            Write-Host "  ✅ Contains: $_" -ForegroundColor $Success
        }

        # Run Maven tests
        Write-Host ""
        Write-Host "Running Maven tests..."
        mvn test
    } else {
        Write-Host "❌ ClaudeNPC.jar not found. Build first (option 1)" -ForegroundColor $Error
    }

    Pop-Location
    Write-Host ""
    Write-Host "Press any key to continue..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Create-PrismInstance {
    Write-Host "🎮 Creating Prism Launcher instance..." -ForegroundColor $Hope

    $instancesPath = "$env:APPDATA\PrismLauncher\instances"

    if (Test-Path $instancesPath) {
        Write-Host "✅ Instances folder: $instancesPath" -ForegroundColor $Success
        Write-Host ""
        Write-Host "Recommended instances to create in Prism Launcher:"
        Write-Host "  1. ClaudeNPC-Quantum   (Minecraft 1.20.1, testing)"
        Write-Host "  2. ClaudeNPC-Dev       (Minecraft 1.20.1, development)"
        Write-Host "  3. QuantumEducation    (Minecraft 1.20.1, classroom)"
        Write-Host ""
        Write-Host "See: PRISM_LAUNCHER_INTEGRATION.md for setup guide"
    } else {
        Write-Host "❌ Prism Launcher instances folder not found" -ForegroundColor $Error
    }

    Write-Host ""
    Write-Host "Press any key to continue..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Run-Diagnostics {
    Write-Host "🔍 Running full system diagnostics..." -ForegroundColor $Hope
    Write-Host ""

    # Check all repos
    Write-Host "Checking repositories..."
    $repos = @(
        "$HOME\SpiralSafe-FromGitHub",
        "$HOME\repos\SpiralSafe",
        "$HOME\repos\ClaudeNPC-Server-Suite",
        "$HOME\quantum-redstone"
    )

    foreach ($repo in $repos) {
        if (Test-Path $repo) {
            Push-Location $repo
            $branch = git branch --show-current 2>&1
            $status = git status --porcelain 2>&1
            $clean = if ($status.Length -eq 0) { "✅ Clean" } else { "⚠️  Changes" }
            Write-Host "  $repo [$branch] $clean"
            Pop-Location
        }
    }

    Write-Host ""
    Write-Host "Checking Python packages..."
    pip list | Select-String "torch|numpy|qiskit|transformers" | ForEach-Object {
        Write-Host "  ✅ $_" -ForegroundColor $Success
    }

    Write-Host ""
    Write-Host "Press any key to continue..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

function Optimize-EDrive {
    Write-Host "💾 E: Drive Optimization Plan" -ForegroundColor $Hope
    Write-Host ""
    Write-Host "This will create optimized structure on E: drive:"
    Write-Host ""
    Write-Host "E:\"
    Write-Host "├── SpiralSafe\"
    Write-Host "│   ├── atom-trails\      (move ATOM data here)"
    Write-Host "│   ├── docker-volumes\   (Docker persistent data)"
    Write-Host "│   └── minecraft-servers\ (test servers)"
    Write-Host "├── Python-Envs\"
    Write-Host "│   └── claudenpc-env\    (isolated Python environment)"
    Write-Host "└── Build-Cache\"
    Write-Host "    ├── maven\            (Maven local repo)"
    Write-Host "    └── npm\              (npm cache)"
    Write-Host ""

    $confirm = Read-Host "Create this structure? (Y/N)"

    if ($confirm -eq "Y" -or $confirm -eq "y") {
        Write-Host "Creating directories..."

        New-Item -ItemType Directory -Force -Path "E:\SpiralSafe\atom-trails" | Out-Null
        New-Item -ItemType Directory -Force -Path "E:\SpiralSafe\docker-volumes" | Out-Null
        New-Item -ItemType Directory -Force -Path "E:\SpiralSafe\minecraft-servers" | Out-Null
        New-Item -ItemType Directory -Force -Path "E:\Python-Envs" | Out-Null
        New-Item -ItemType Directory -Force -Path "E:\Build-Cache\maven" | Out-Null
        New-Item -ItemType Directory -Force -Path "E:\Build-Cache\npm" | Out-Null

        Write-Host "✅ Directory structure created!" -ForegroundColor $Success
        Write-Host ""
        Write-Host "Next steps:"
        Write-Host "1. Update docker-compose.yml volumes to point to E:\SpiralSafe\docker-volumes"
        Write-Host "2. Update ClaudeNPC config to use E:\SpiralSafe\atom-trails"
        Write-Host "3. Set MAVEN_OPTS=-Dmaven.repo.local=E:\Build-Cache\maven"
    } else {
        Write-Host "❌ Cancelled" -ForegroundColor $Warning
    }

    Write-Host ""
    Write-Host "Press any key to continue..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# Main menu loop
while ($true) {
    Show-Header
    Show-SystemStatus
    Show-ProjectStatus
    Show-DiskSpace
    Show-QuickActions

    $choice = Read-Host "Select action"

    switch ($choice.ToUpper()) {
        "1" { Build-ClaudeNPC }
        "2" { Generate-QuantumCircuits }
        "3" { Run-ValidationTests }
        "4" { Start-DockerBridges }
        "5" { Open-PrismLauncher }
        "6" { View-ATOMTrail }
        "7" { Test-ClaudeNPCBuild }
        "8" { Create-PrismInstance }
        "9" { Run-Diagnostics }
        "10" { Optimize-EDrive }
        "R" { continue }
        "Q" { Write-Host "The Evenstar Guides Us ✦" -ForegroundColor $Hope; exit }
        default { Write-Host "Invalid choice" -ForegroundColor $Warning; Start-Sleep -Seconds 1 }
    }
}
