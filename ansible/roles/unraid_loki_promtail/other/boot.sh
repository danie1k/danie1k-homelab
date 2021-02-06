logger 'Configuring Loki & Promtail'

if [ -f "{{ unraid.homelab_dir }}/loki_promtail/syslog.conf" ]
then
  fromdos < "{{ unraid.homelab_dir }}/loki_promtail/syslog.conf" > /etc/rsyslog.d/loki_promtail.conf
  /etc/rc.d/rc.rsyslogd reload
fi

for item in logcli loki promtail
do
  cp -vf "{{ unraid.homelab_dir }}/loki_promtail/${item}-linux-amd64" /usr/bin/${item}
  chmod +x /usr/bin/${item}

  if [ -f "{{ unraid.homelab_dir }}/loki_promtail/${item}.conf.yaml" ]
  then
    fromdos < "{{ unraid.homelab_dir }}/loki_promtail/${item}.conf.yaml" > "/etc/${item}.conf.yaml"
  fi
done
