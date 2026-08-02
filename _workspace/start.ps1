# start.ps1 — levanta node server.js en :3000 (idempotente) y regenera el catalogo
param([int]$Port = 3000)

$ROOT      = "C:\Users\alejandro.gallegos\OneDrive - Accenture\Documents\Digital Core"
$SERVER_JS = "$ROOT\_workspace\server.js"

$listening = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
if (-not $listening) {
  $psArgs = "-NoProfile -NonInteractive -ExecutionPolicy Bypass -Command `"node '$SERVER_JS'`""
  Start-Process "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -WindowStyle Hidden -ArgumentList $psArgs
  Start-Sleep -Milliseconds 900
  Write-Host "[devserver] node server.js iniciado en http://localhost:$Port"
} else {
  Write-Host "[devserver] ya escuchando en :$Port"
}

& "$ROOT\_workspace\build-catalog.ps1" -Port $Port