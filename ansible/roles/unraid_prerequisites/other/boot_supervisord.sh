logger 'Configuring Supervisord'

mkdir -p /etc/supervisor.d/

if [ -f "{{ unraid.homelab_dir }}/supervisord/supervisord.conf" ]
then
  fromdos < "{{ unraid.homelab_dir }}/supervisord/supervisord.conf" > /etc/supervisord.conf
fi

if [ -f "{{ unraid.homelab_dir }}/supervisord/rc.supervisord" ]
then
  fromdos < "{{ unraid.homelab_dir }}/supervisord/rc.supervisord" > /etc/rc.d/rc.supervisord
  chmod +x /etc/rc.d/rc.supervisord
fi

if [ -d "{{ unraid.homelab_dir }}/supervisord/supervisor.d" ]
then
  shopt -s nullglob
  for file in "{{ unraid.homelab_dir }}/supervisord/supervisor.d/"*.conf
  do
    fromdos < "${file}" > "/etc/supervisor.d/$(basename "${file}")"
  done
  shopt -u nullglob
fi
