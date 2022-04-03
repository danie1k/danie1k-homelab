#!/usr/bin/env bash

readonly ACTION="${1}"

if [[ "${ACTION}" == "tls" ]]
then
  /usr/bin/get_tls_from_pfsense.sh
  docker restart traefik &
  /usr/bin/update_idrac_tls.sh
fi
