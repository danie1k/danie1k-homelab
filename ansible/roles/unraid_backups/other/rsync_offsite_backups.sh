#!/bin/bash
set -e

rsync_targets=(
  {% for item in lab.backup.targets %}"{{ item }}"{% endfor %}

)
ssh_key="{{ lab.backup.ssh_key }}"
ssh_target="{{ lab.backup.ssh_target }}"
timestamp="$(date '+%Y-%m-%d-%H-%M')"

# --delete           --  delete extraneous files from destination dirs
# --delete-delay     --  find deletions during, delete afte
# --delete-excluded  --  also delete excluded files from destination dirs
# -D                 --  same as --devices --specials
# -P                 --  same as --partial --progress
# -h                 --  output numbers in a human-readable format
# -i                 --  output a change-summary for all updates
# -l                 --  copy symlinks as symlinks
# -q                 -- suppress non-error messages
# -r                 --  recurse into directories
# -t                 --  preserve modification times
# -z                 --  compress file data during the transfer
#
# --devices          preserve device files (super-user only)
# --partial          keep partially transferred files
# --progress         show progress during transfer
# --specials         preserve special files

for item in "${rsync_targets[@]}"
do
  read -ra item_arr <<<"$item"

  echo -n "Processing ${item_arr[1]} -> ${ssh_target}:${item_arr[2]} backup... "

  rsync \
    --delete \
    --delete-delay \
    --delete-excluded \
    --log-file="/var/log/rsync-${timestamp}-${item_arr[0]}.log" \
    -D \
    -P \
    -e "ssh -i '${ssh_key}'" \
    -h \
    -i \
    -l \
    -q \
    -r \
    -t \
    -z \
    "${item_arr[1]}" \
    ${ssh_target}:"${item_arr[2]}" \
    2> "/var/log/rsync-${timestamp}-_errors.log" \
    && echo "Done." || echo "Error!"
done

echo
echo "ALL DONE. RSYNC LOGS STORED IN '/var/log/rsync-${timestamp}-*.log' FILES"
