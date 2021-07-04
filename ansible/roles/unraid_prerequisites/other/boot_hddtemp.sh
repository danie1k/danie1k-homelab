logger 'Configuring hddtemp'

if [ -f "{{ unraid.homelab_dir }}/hddtemp/rc.hddtemp" ]
then
  fromdos < "{{ unraid.homelab_dir }}/hddtemp/rc.hddtemp" > /etc/rc.d/rc.hddtemp
  chmod +x /etc/rc.d/rc.hddtemp
fi
