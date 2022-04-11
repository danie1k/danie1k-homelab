{% raw %}#!/usr/bin/env bash

containers_list=$(docker container ls --all --filter 'status=exited' --quiet)


for container_id in ${containers_list}
do
  container_name="$(docker container inspect "${container_id}" | jq -rM '.[0].Config.Hostname')"
  echo "Container ID: ${container_name} (${container_id})"

  readarray -t container_networks <<< "$(docker inspect "${container_id}" | jq '.[0].NetworkSettings.Networks' | jq 'keys' | jq -rM '.[]')"
  readarray -t networks_ips <<< "$(docker inspect "${container_id}" | jq -rM '.[0].NetworkSettings.Networks[].IPAMConfig.IPv4Address')"

  for (( idx=${#container_networks[@]}-1 ; idx>=0 ; idx-- )) ; do
    network_name="${container_networks[idx]}"
    echo "   disconnecting: ${network_name}"
    docker network disconnect "${network_name}" "${container_id}"
  done

  for (( idx=0 ; idx<${#container_networks[@]} ; idx++ )) ; do
    network_name="${container_networks[idx]}"
    network_ip="${networks_ips[idx]}"
    if [[ "${network_ip}"  == 'null' ]]
    then
      echo "   connecting: ${network_name}"
      docker network connect "${network_name}" "${container_id}"
    else
      echo "   connecting: ${network_name}, with IP: ${network_ip}"
      docker network connect --ip "${network_ip}" "${network_name}" "${container_id}"
    fi
  done

  echo
done
{% endraw %}
