#!/bin/sh
set -e

if [ ! -f /opt/serviio/bin/serviio.sh ]
then
  echo '*****************************************************************************'
  echo '** First-run Serviio installation...                                       **'
  echo '*****************************************************************************'
  cp -rf --verbose /serviio_src/* /opt/serviio

  PUID="${PUID:-911}"
  PGID="${PGID:-911}"
  groupmod -o -g "${PGID}" abc
  usermod -o -u "${PUID}" abc

  chown -Rv abc:abc /opt/serviio
  chmod -Rv 774 /opt/serviio
  echo '*****************************************************************************'
  echo '** First-run installation done!                                            **'
  echo '*****************************************************************************'
  echo
  echo
fi

# Allow non-root write to sdtout & stderr (https://github.com/moby/moby/issues/31243#issuecomment-402105707)
chmod o+w /proc/1/fd/1 /proc/1/fd/2 /dev/stdout /dev/stderr

chown -R abc:abc /opt/serviio
chmod -R 777 /opt/serviio

exec su -s /bin/sh abc -c '/opt/serviio/bin/serviio.sh'
