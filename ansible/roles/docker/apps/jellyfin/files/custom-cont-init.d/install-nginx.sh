#!/usr/bin/with-contenv bash
set -e

if ! dpkg -l nginx 1>/dev/null 2>&1; then
  export DEBIAN_FRONTEND=noninteractive

  apt-get update
  apt-get install -y --no-upgrade --no-install-recommends --no-install-suggests nginx

  apt-get clean
  rm -rf /var/lib/apt/lists/*
fi
