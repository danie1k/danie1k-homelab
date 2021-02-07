logger 'Configuring Telegraf'

mkdir -p /etc/telegraf.d/

cp -vf "{{ unraid.homelab_dir }}/telegraf/telegraf" /usr/bin/telegraf
chmod +x /usr/bin/telegraf

shopt -s nullglob
for file in "{{ unraid.homelab_dir }}/telegraf/"*.conf
do
  fromdos < "${file}" > "/etc/telegraf.d/$(basename "${file}")"
done
shopt -u nullglob
