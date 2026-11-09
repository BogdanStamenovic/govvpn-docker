# openconnect + ocproxy only. ocproxy gives the VPN a userspace network stack,
# so the container needs no tun device and no NET_ADMIN, and the host gets no routes.
FROM debian:stable-slim
RUN apt-get update \
 && apt-get install -y --no-install-recommends openconnect ocproxy ca-certificates \
 && rm -rf /var/lib/apt/lists/* \
 && useradd -m -u 1000 vpn
USER vpn
