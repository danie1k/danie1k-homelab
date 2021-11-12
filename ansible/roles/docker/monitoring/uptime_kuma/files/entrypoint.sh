#!/usr/bin/env sh
set -e

# https://github.com/louislam/uptime-kuma/blob/master/extra/entrypoint.sh

PUID=${PUID=0}
PGID=${PGID=0}

echo "==> Starting application with user ${PUID} group ${PGID}"

# --clear-groups Clear supplementary groups.
exec setpriv --reuid "${PUID}" --regid "${PGID}" --clear-groups "${@}"
