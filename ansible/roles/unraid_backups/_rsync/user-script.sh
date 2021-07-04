#!/bin/bash
set -e

timestamp="$(date '+%Y-%m-%d-%H-%M')"
remote='{{ unraid_backups.rsync.ssh_target }}'
declare -A sync_targets

rsync_options=(
  --delete           # delete extraneous files from destination dirs
  --delete-delay     # find deletions during, delete after
  --delete-excluded  # also delete excluded files from destination dirs
  -D                 # same as --devices --specials
  --exclude-from     # read exclude patterns from FILE
  '{{ unraid.homelab_dir }}/unraid_backups/rsync-exclude.txt'
  -e                 # specify the remote shell to use
  "ssh -i '{{ unraid_backups.rsync.ssh_key }}'"
  -h                # output numbers in a human-readable format
  -i                # output a change-summary for all updates
  -l                # copy symlinks as symlinks
  -q                # suppress non-error messages
  -r                # recurse into directories
  -t                # preserve modification times
  --verbose         # increase verbosity
  -z                # compress file data during the transfer
)
# --devices          preserve device files (super-user only)
# --partial          keep partially transferred files
#
# --specials         preserve special files

if [[ "$@" == *'dry-run'* ]]; then
  rsync_options+=(
    --dry-run       # perform a trial run with no changes made
    --progress      # show progress during transfer
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

  _log_file_path="/var/log/rsync-${timestamp}-${name}.log"
  _header_msg="Processing backup no. ${i} of: ${local_path} -> ${remote}:${remote_path}"

  echo "${_header_msg}"
  echo "Writing logs to '${_log_file_path}' file"
  echo "${_header_msg}" > "${_log_file_path}"
  echo

  sync_params=("${rsync_options[@]}")
  if [[ "$@" != *'dry-run'* ]]; then
    sync_params+=(
      --log-file  # log what we're doing to the specified FILE
      "${_log_file_path}"
    )
  fi

  sync_params+=(
    "${local_path}"
    "${remote}:${remote_path}"
  )

  if [[ "$@" == *'debug'* ]]; then
    echo -n 'DEBUG: /usr/bin/rsync'
    printf ' "%s"' "${sync_params[@]}"
    echo
  else
    /usr/bin/rsync "${sync_params[@]}"
    echo "Done."
    echo
    cat "${_log_file_path}"
  fi
done
