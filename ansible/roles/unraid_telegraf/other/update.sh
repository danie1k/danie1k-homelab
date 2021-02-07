#!/bin/bash

current_version="$(telegraf --version 2>/dev/null | head -n 1 | awk '{print $2}')"
latest_version="$(curl -s https://api.github.com/repos/influxdata/telegraf/releases/latest | jq -r .tag_name | cut -c2-)"

if [ "${current_version}" == "${latest_version}" ]
then
  echo "No newer version found."
  exit 0
fi

cd /var/tmp/
wget -c "https://dl.influxdata.com/telegraf/releases/telegraf-${latest_version}_linux_amd64.tar.gz" -O - | tar -xz

cp -vf "/var/tmp/telegraf-${latest_version}/usr/bin/telegraf" "{{ unraid.homelab_dir }}/telegraf/telegraf"
cp -vf "/var/tmp/telegraf-${latest_version}/usr/bin/telegraf" /usr/bin/telegraf
chmod +x /usr/bin/telegraf

cd /
rm -rf "/var/tmp/telegraf-${latest_version}"

echo "DONE. PLEASE RESTART YOUR SERVICES."
