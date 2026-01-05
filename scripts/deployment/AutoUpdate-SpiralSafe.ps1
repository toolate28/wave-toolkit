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
