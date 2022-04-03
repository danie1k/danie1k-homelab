#!/bin/sh

mkdir -p '{{ tmpfs.mountpoint }}/influxdb/wal'
mkdir -p '{{ _influx_config.dir.data }}'
mkdir -p '{{ _influx_config.dir.meta }}'
chown -R {{ docker_config.default_user }} '{{ tmpfs.mountpoint }}/influxdb'
chown -R {{ docker_config.default_user }} '{{ zfs.mountpoint }}/influxdb'/*

exec /usr/bin/influxd run -config /etc/influxdb/config.toml
