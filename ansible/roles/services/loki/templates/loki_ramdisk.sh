#!/bin/bash

# Inspired by https://docs.observium.org/persistent_ramdisk/


case "${1}" in
  start)
    pgrep -fx /usr/bin/loki >/dev/null 2>&1 && echo "Loki is running, exiting" && exit 1

    echo 'Mounting ZFS dataset'
    zfs mount '{{ tmpfs.mountpoint }}/loki'

    echo 'Copying files to ramdisk'
    rsync -av '{{ zfs.mountpoint }}/loki'/ '{{ tmpfs.mountpoint }}/loki'/
    echo [`date +"%Y-%m-%d %H:%M"`] Ramdisk Synched from HD >> /var/log/ramdisk_sync.log

    echo "Starting Loki"
    nohup /usr/bin/loki -config.file /etc/loki/config.yaml >> /var/log/loki-nohup.log &
    ;;
  sync)
    echo 'Syncing files from ramdisk to Harddisk'
    echo [`date +"%Y-%m-%d %H:%M"`] Ramdisk Synched to HD >> /var/log/ramdisk_sync.log
    rsync -av --delete --recursive --force '{{ tmpfs.mountpoint }}/loki'/ '{{ zfs.mountpoint }}/loki'/
    ;;
  stop)
    echo 'Syncing logfiles from ramdisk to Harddisk'
    echo [`date +"%Y-%m-%d %H:%M"`] Ramdisk Synched to HD >> /var/log/ramdisk_sync.log
    rsync -av --delete --recursive --force '{{ tmpfs.mountpoint }}/loki'/ '{{ zfs.mountpoint }}/loki'/

    if pgrep -fx /usr/bin/loki >/dev/null 2>&1
    then
      echo "Stopping Loki"
      kill "$(pgrep -f /usr/bin/loki)"
    fi
    ;;
  *)
    echo "Usage: ${0} {start|stop|sync}"
    exit 1
    ;;
esac

exit 0

