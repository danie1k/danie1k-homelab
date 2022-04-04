#!/usr/bin/env bash

if [ -f '{{ unraid.dotenv}}' ]; then
  export $(cat '{{ unraid.dotenv }}' {% raw %}| grep -v '#' | sed 's/\r$//' | awk '/=/ {print $1}'){% endraw %}{{''}}
fi

readonly ACTION="${1}"

if [[ "${ACTION}" == "tls" ]]
then
  /usr/bin/get_tls_from_pfsense.sh
  docker restart jellyfin &
  docker restart traefik &
  /usr/bin/update_idrac_tls.sh
fi
