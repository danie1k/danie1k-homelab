#!/usr/bin/env bash

install_path="{{ _install_path }}"
latest_version="$(find "${install_path}" -mindepth 1 -maxdepth 1 -type d -regextype posix-egrep -regex ".*[0-9]+\.[0-9]+\.[0-9]+$" | sort -h | tail -n 1)"

_rc_lookup_dir="${install_path}/etc/rc.d"
_rc_target_dir="/etc/rc.d/"

_rsyslog_lookup_dir="${install_path}/etc/rsyslog.d"
_rsyslog_target_dir="/etc/rsyslog.d"

_yaml_lookup_dir="${install_path}/etc"
_yaml_target_dir="/etc"


for name in logcli loki promtail
do
  if [ ! -f "/usr/bin/${name}" ]
  then
    echo "Installing ${name} binary"
    cp -v "${latest_version}/${name}"* "/usr/bin/${name}"
    chmod +x "/usr/bin/${name}"
  fi

  if [ -f "${_rc_lookup_dir}/rc.${name}" ] && [ ! -f "${_rc_target_dir}/rc.${name}" ]
  then
    echo "Installing ${name} rc run script"
    fromdos < "${_rc_lookup_dir}/rc.${name}" > "${_rc_target_dir}/rc.${name}"
    chmod +x "${_rc_target_dir}/rc.${name}"
  fi

  if [ -f "${_yaml_lookup_dir}/${name}.yaml" ] && [ ! -f "${_yaml_target_dir}/${name}.yaml" ]
  then
    echo "Installing ${name} config file"
    fromdos < "${_yaml_lookup_dir}/${name}.yaml" > "${_yaml_target_dir}/${name}.yaml"
  fi
done


#if [ -f "${_rsyslog_lookup_dir}/00-loki-promtail.conf" ] && [ ! -f "${_rsyslog_target_dir}/00-loki-promtail.conf" ]
#then
#  echo "Installing rsyslog config file"
#  fromdos < "${_rsyslog_lookup_dir}/00-loki-promtail.conf" > "${_rsyslog_target_dir}/00-loki-promtail.conf"
#fi


if ! docker plugin ls --filter "capability=logdriver" | grep "loki"
then
  # https://grafana.com/docs/loki/v2.1.0/clients/docker-driver/
  echo "Installing Loki Docker logging driver plugin"
  docker plugin install grafana/loki-docker-driver:latest --alias loki --grant-all-permissions
fi
