#!/usr/bin/with-contenv bash
set -e

# Allow non-root user to bind to tcp port < 1024
# https://unix.stackexchange.com/a/10737

if ! dpkg -l libcap2-bin 1>/dev/null 2>&1; then
  export DEBIAN_FRONTEND=noninteractive

  apt-get update
  apt-get install -y --no-upgrade --no-install-recommends --no-install-suggests libcap2-bin

  apt-get clean
  rm -rf /var/lib/apt/lists/*
fi

setcap cap_net_bind_service=ep /usr/lib/jellyfin/bin/jellyfin
