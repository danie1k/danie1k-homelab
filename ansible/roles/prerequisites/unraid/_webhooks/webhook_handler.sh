#!/usr/bin/env bash

if [ -f '{{ unraid.dotenv}}' ]; then
  export $(cat '{{ unraid.dotenv }}' {% raw %}| grep -v '#' | sed 's/\r$//' | awk '/=/ {print $1}'){% endraw %}{{''}}
fi

readonly ACTION="${1}"

{% raw %}
if [[ "${ACTION}" == "tls" ]]
then
  /usr/bin/get_tls_from_pfsense.sh
  [[ "$(docker ps --filter 'name=^jellyfin$' --format '{{.Names}}' 1>/dev/null 2>&1)" == 'jellyfin' ]] && docker restart jellyfin &
  [[ "$(docker ps --filter 'name=^traefik$' --format '{{.Names}}' 1>/dev/null 2>&1)" == 'traefik' ]] && docker restart traefik &
  /usr/bin/update_idrac_tls.sh
fi
{% endraw %}
