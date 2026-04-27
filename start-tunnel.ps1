# start-tunnel.ps1
# Starts a Cloudflare Quick Tunnel → http://localhost:3141
# Captures the tunnel URL and saves it to store/current-tunnel-url.txt
# The dashboard reads this file via /api/tunnel-url to auto-fill the API URL.

$cloudflared  = "C:\Users\Callbox\cloudflared.exe"
$logFile      = Join-Path $PSScriptRoot "store\tunnel.log"
$urlFile      = Join-Path $PSScriptRoot "store\current-tunnel-url.txt"

if (-not (Test-Path $cloudflared)) {
    Write-Host "ERROR: cloudflared.exe not found at $cloudflared"
    Write-Host "Install it: winget install cloudflare.cloudflared"
    exit 1
}

# Clear stale URL from previous session
if (Test-Path $urlFile) { Remove-Item $urlFile -Force }

Write-Host ""
Write-Host "Starting Cloudflare Quick Tunnel → http://localhost:3141"
Write-Host "Waiting for tunnel URL..."
Write-Host ""

$psi                       = New-Object System.Diagnostics.ProcessStartInfo
$psi.FileName              = $cloudflared
$psi.Arguments             = "tunnel --url http://localhost:3141"
$psi.UseShellExecute       = $false
$psi.RedirectStandardError = $true
$psi.CreateNoWindow        = $false

$process = New-Object System.Diagnostics.Process
$process.StartInfo = $psi

$urlCaptured = $false

$handler = {
    $line = $Event.SourceEventArgs.Data
    if (-not $line) { return }

    # Append to log
    Add-Content -Path $using:logFile -Value $line

    # Extract trycloudflare URL
    if ($line -match "https://[a-z0-9\-]+\.trycloudflare\.com") {
        $url = $Matches[0]
        Set-Content -Path $using:urlFile -Value $url -Encoding UTF8
        Write-Host ""
        Write-Host "===================================================="
        Write-Host "  Tunnel URL: $url"
        Write-Host "===================================================="
        Write-Host ""
        Write-Host "Update your dashboard Settings -> API URL with this."
        Write-Host "Or click 'Load Tunnel URL' in the dashboard Settings."
        Write-Host ""
    }
}

Register-ObjectEvent -InputObject $process -EventName ErrorDataReceived -Action $handler | Out-Null

$process.Start()        | Out-Null
$process.BeginErrorReadLine()

Write-Host "Tunnel running (Ctrl+C to stop)..."
$process.WaitForExit()
