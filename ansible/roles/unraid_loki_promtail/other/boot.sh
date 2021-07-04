logger 'Configuring Loki'

for item in logcli loki
do
  cp -vf "{{ unraid.homelab_dir }}/loki_promtail/${item}-linux-amd64" /usr/bin/${item}
  chmod +x /usr/bin/${item}

  if [ -f "{{ unraid.homelab_dir }}/loki_promtail/${item}.conf.yaml" ]
  then
    fromdos < "{{ unraid.homelab_dir }}/loki_promtail/${item}.conf.yaml" > "/etc/${item}.conf.yaml"
  fi
done
