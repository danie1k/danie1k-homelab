#!/bin/bash
set -e

export RCLONE_CONFIG=/boot/config/plugins/rclone/.rclone.conf

timestamp="$(date '+%Y-%m-%d-%H-%M')"
declare -A sync_targets

rclone_flags=(
  --copy-links   # Follow symlinks and copy the pointed to item
  --filter-from  # Read filtering patterns from a file (use - to read from stdin)
  '{{ unraid.homelab_dir }}/unraid_backups/rclone-filters.txt'
  --verbose      # Print lots more stuff (repeat for more)
)

if [[ "$@" == *'dry-run'* ]]; then
  rclone_flags+=(
    --dry-run    # Do a trial run with no permanent changes
    --progress   # Real-time transfer statistics
  )
fi

{% for key, value in unraid_backups.sync_targets.items() %}
sync_targets[{{ loop.index }},0]="{{ key }}"
sync_targets[{{ loop.index }},1]="{{ value.local_path }}"
sync_targets[{{ loop.index }},2]="{{ value.remote_path }}"
{% endfor %}

for i in {1..{{ unraid_backups.sync_targets | length }}}; do
  name="${sync_targets[$i,0]}"
  local_path="${sync_targets[$i,1]}"
  remote_path="${sync_targets[$i,2]}"

  _log_file_path="/var/log/rclone-${timestamp}-${name}.log"
  _header_msg="Processing backup no. ${i} of: ${local_path} -> {{ _rclone_config_remote_name }}:${remote_path}"

  echo "${_header_msg}"
  echo "Writing logs to '${_log_file_path}' file"
  echo "${_header_msg}" > "${_log_file_path}"
  echo

  sync_params=("${rclone_flags[@]}")
  if [[ "$@" != *'dry-run'* ]]; then
    sync_params+=(
      --log-file  # Log everything to this file
      "${_log_file_path}"
    )
  fi

  sync_params+=(
    "${local_path}"
    "{{ _rclone_config_remote_name }}:${remote_path}"
  )

  if [[ "$@" == *'debug'* ]]; then
    echo -n 'DEBUG: /usr/sbin/rclone sync'
    printf ' "%s"' "${sync_params[@]}"
    echo
  else
    /usr/sbin/rclone sync "${sync_params[@]}"
    echo "Done."
    echo
    cat "${_log_file_path}"
  fi
done
