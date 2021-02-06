#!/bin/bash

current_version="v$(loki --version 2>/dev/null | head -n 1 | awk '{print $3}')"
latest_version="$(curl -s https://api.github.com/repos/grafana/loki/releases/latest | jq -r .tag_name)"

if [ "${current_version}" == "${latest_version}" ]
then
  echo "No newer version found."
  exit 0
fi

echo "UPDATING FROM ${current_version} TO ${latest_version}..."

for item in logcli loki promtail
do
  echo "Processing ${item}..."
  wget -O "/var/tmp/${item}.zip" "https://github.com/grafana/loki/releases/download/${latest_version}/${item}-linux-amd64.zip"
  unzip -o -d "{{ unraid.homelab_dir }}/loki_promtail/" "/var/tmp/${item}.zip"
  rm -f "/var/tmp/${item}.zip"

  cp -vf "{{ unraid.homelab_dir }}/loki_promtail/${item}-linux-amd64" /usr/bin/${item}
  chmod +x /usr/bin/${item}

done

echo
echo "DONE. PLEASE RESTART YOUR SERVICES."
