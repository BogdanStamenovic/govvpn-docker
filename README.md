# govvpn-docker

Connects to the National AI Platform VPN (InnovNation) **from inside a Docker container only**. Nothing is installed on your computer, no network adapter is added, and your routes don't change. Your normal internet is untouched while it's connected.

## How it works

- The container runs `openconnect` against `https://gw.uzzpro.gov.rs/sqlatos`, using `ocproxy` as its network stack. `ocproxy` works in userspace, so the container needs no tun device, no `NET_ADMIN` and no root. It runs with `--cap-drop ALL`, a read-only filesystem and a non-root user.
- These ports open on `127.0.0.1` only (nobody else on your network can reach them):

| Local port | Goes to | Use |
|---|---|---|
| 1080 | SOCKS5 into the VPN | the browser launcher uses this |
| 8443 | 10.68.6.58:443 | platform HTTPS |
| 2222 | 10.68.6.58:22 | platform SSH: `ssh -p 2222 USER@127.0.0.1` |
| 8888 | 10.36.1.162:8888 | their HTTP proxy (it asks for credentials, HTTP 407) |

- **Why a separate browser:** the platform GUI sends you to log in at `https://10.68.6.58/auth` (hard-coded in its Keycloak config). Opening `https://localhost:8443` in a normal browser therefore loads forever. The launcher opens a separate Chrome/Edge profile that goes through the SOCKS port, so `10.68.6.58` works. Your normal browser profile isn't affected. That profile can reach only the VPN, not the internet.

## Windows 10

1. Install **Docker Desktop** (it needs WSL 2; the installer offers it) and start it. Wait until it says it's running.
2. Download this repo: green **Code** button → **Download ZIP**, then unzip it. Or use `git clone`.
3. Open the `windows` folder and double-click **`connect.cmd`**. Enter your VPN username (`ime.prezime`), then the password from the eUprava SMS. The first run builds the image, which takes about a minute.
   Leave that window open. Closing it or pressing Ctrl+C disconnects.
4. Double-click **`browser.cmd`**. Accept the certificate warning (their certificate doesn't match the IP), then log in with your **platform** credentials.

## Linux

```sh
linux/connect ime.prezime    # asks for the SMS password; leave it running
linux/browser                # second terminal; needs google-chrome-stable
```
If `docker build` complains about buildx, run `DOCKER_BUILDKIT=0 docker build -t govvpn .` once.

## Troubleshooting

- **`Login failed.`**: usually a typo in the SMS password. Don't retry many times. If it keeps failing, the code may be single-use, so ask for a new one.
- **`Failed to open /dev/vhost-net`**: harmless and expected, because the container has no access to it on purpose.
- **Why did it disconnect?** Run `docker logs govvpn`. The stopped container is kept until the next connect for this reason.
- **Browser loads forever**: the VPN isn't connected, or you used your normal browser instead of the launcher.

## Limitations

- **The Windows scripts were written on Linux and have never been run on Windows.** The Linux version connected and reached the GUI, SSH and proxy ports on 2026-11-09. The browser launcher had not yet been tested end to end with a login.
- The browser profile has no internet access through the VPN (the VPN gives none), so any page that pulls in outside resources won't load them.
- Their proxy on 8888 needs credentials that this setup doesn't provide.
- Addresses are hard-coded for this platform. If they change, edit `connect.ps1` / `linux/connect`.
