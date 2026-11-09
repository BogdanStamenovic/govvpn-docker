# Usage: connect.cmd USERNAME  (or double-click connect.cmd and type it). It asks for the password from the eUprava SMS.
# Ctrl+C disconnects. Published on 127.0.0.1 only: 8443->platform https, 2222->platform ssh, 1080->SOCKS, 8888->their proxy
param([string]$User)
if (-not $User) { $User = Read-Host 'VPN username (e.g. ime.prezime)' }
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  Write-Host 'Docker not found. Install Docker Desktop and start it first.'; exit 1 }
docker image inspect govvpn *> $null
if ($LASTEXITCODE -ne 0) {
  docker build -t govvpn (Join-Path $PSScriptRoot '..')
  if ($LASTEXITCODE -ne 0) { Write-Host 'Build failed. Is Docker Desktop running?'; exit 1 }
}
docker rm -f govvpn *> $null
docker run -it --name govvpn `
  --cap-drop ALL --security-opt no-new-privileges --read-only --tmpfs /tmp --tmpfs /home/vpn:uid=1000 `
  -p 127.0.0.1:8443:8443 -p 127.0.0.1:2222:2222 -p 127.0.0.1:1080:1080 -p 127.0.0.1:8888:8888 `
  govvpn openconnect "--user=$User" `
  --script-tun --script 'ocproxy -g -D 1080 -L 8443:10.68.6.58:443 -L 2222:10.68.6.58:22 -L 8888:10.36.1.162:8888' `
  https://gw.uzzpro.gov.rs/sqlatos
