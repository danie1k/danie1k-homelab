logger 'Configuring unraid_backups'

mkdir -p /etc/sanoid/

if [ -f "{{ unraid.homelab_dir }}/unraid_backups/sanoid.conf" ]
then
  fromdos < "{{ unraid.homelab_dir }}/unraid_backups/sanoid.conf" > /etc/sanoid/sanoid.conf
fi

# Install crotnab entry
(
  crontab -l 2>/dev/null
  echo
  echo "# Sanoid ZFS snapshot management"
  echo "* * * * * /usr/local/sbin/sanoid --cron 1> /dev/null"
) | crontab -
