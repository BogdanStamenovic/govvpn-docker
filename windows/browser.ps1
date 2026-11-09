# Opens the platform in a separate browser profile whose only network is the VPN container's SOCKS port.
# Needed because the platform's login page is hard-coded to https://10.68.6.58/auth.
$candidates = @(
  "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
  "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe",
  "$env:LOCALAPPDATA\Google\Chrome\Application\chrome.exe",
  "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe",
  "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe")
$exe = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $exe) { Write-Host 'Neither Chrome nor Edge found.'; exit 1 }
$profileDir = Join-Path $env:LOCALAPPDATA 'govvpn-browser'
Start-Process $exe -ArgumentList "--user-data-dir=`"$profileDir`"", '--proxy-server=socks5://127.0.0.1:1080', '--no-first-run', 'https://10.68.6.58/gui/'
