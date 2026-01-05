# PARALLEL DEPLOYMENT SCRIPT
# Deploys SpiralSafe to all Cloudflare services simultaneously

Write-Host "=== PARALLEL CLOUDFLARE DEPLOYMENT ===" -ForegroundColor Cyan

$jobs = @()

# Job 1: Deploy to Cloudflare Workers
$jobs += Start-Job -ScriptBlock {
    Set-Location C:\Users\iamto\SpiralSafe-FromGitHub\cloudflare-workers-deployment
    python build.py
    # Note: Uncomment when account_id is configured in wrangler.toml
    # wrangler deploy
    return "[WORKERS] Build complete. Configure account_id in wrangler.toml, then run: wrangler deploy"
}

# Job 2: Deploy to Cloudflare Pages
$jobs += Start-Job -ScriptBlock {
    Set-Location C:\Users\iamto\SpiralSafe-FromGitHub\SpiralSafe
    # Note: Uncomment when ready to deploy
    # wrangler pages deploy . --project-name=spiralsafe-pages
    return "[PAGES] Ready to deploy. Run: wrangler pages deploy . --project-name=spiralsafe-pages"
}

# Job 3: Configure Cloudflare Tunnel
$jobs += Start-Job -ScriptBlock {
    # Check if tunnel exists
    $tunnelExists = cloudflared tunnel list 2>$null | Select-String "spiralsafe-tunnel"
    if (!$tunnelExists) {
        return "[TUNNEL] Create tunnel: cloudflared tunnel create spiralsafe-tunnel"
    } else {
        return "[TUNNEL] Tunnel already exists. Run: cloudflared tunnel run spiralsafe-tunnel"
    }
}

# Wait for all jobs to complete
Write-Host "Deploying in parallel..." -ForegroundColor Yellow
$results = $jobs | Wait-Job | Receive-Job

# Display results
Write-Host "`n=== DEPLOYMENT RESULTS ===" -ForegroundColor Green
foreach ($result in $results) {
    Write-Host $result -ForegroundColor Gray
}

# Cleanup
$jobs | Remove-Job

Write-Host "`n=== NEXT STEPS ===" -ForegroundColor Cyan
Write-Host "1. Get Cloudflare Account ID:" -ForegroundColor Yellow
Write-Host "   wrangler whoami" -ForegroundColor Gray
Write-Host "`n2. Update wrangler.toml with your account_id" -ForegroundColor Yellow
Write-Host "`n3. Deploy Workers:" -ForegroundColor Yellow
Write-Host "   cd SpiralSafe-FromGitHub\cloudflare-workers-deployment" -ForegroundColor Gray
Write-Host "   wrangler deploy" -ForegroundColor Gray
Write-Host "`n4. Deploy Pages:" -ForegroundColor Yellow
Write-Host "   cd SpiralSafe-FromGitHub\SpiralSafe" -ForegroundColor Gray
Write-Host "   wrangler pages deploy . --project-name=spiralsafe-pages" -ForegroundColor Gray
Write-Host "`n5. Configure and run Tunnel:" -ForegroundColor Yellow
Write-Host "   cloudflared tunnel create spiralsafe-tunnel" -ForegroundColor Gray
Write-Host "   cloudflared tunnel run spiralsafe-tunnel" -ForegroundColor Gray
