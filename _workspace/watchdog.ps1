# watchdog.ps1 — reinicia node server.js si el puerto 3000 no responde
$PORT      = 3000
$SERVER_JS = "C:\Users\alejandro.gallegos\OneDrive - Accenture\Documents\Digital Core\_workspace\server.js"

$up = Get-NetTCPConnection -LocalPort $PORT -State Listen -ErrorAction SilentlyContinue
if (-not $up) {
  $psArgs = "-NoProfile -NonInteractive -ExecutionPolicy Bypass -Command `"node '$SERVER_JS'`""
  Start-Process "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -WindowStyle Hidden -ArgumentList $psArgs
}