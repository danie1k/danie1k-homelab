#!/bin/bash

# Create ZFS pool on a single drive (https://youtu.be/-wlbvt9tM-Q)
#
# >>> $ parted /dev/sdX mklabel gpt
# >>> $ parted /dev/sdX mkpart zfs 0% 25%
# >>> $ parted /dev/sdX mkpart zfs 25% 50%
# >>> $ parted /dev/sdX mkpart zfs 50% 75%
# >>> $ parted /dev/sdX mkpart zfs 75% 100%
#
# >>> $ zpool create -m /path/to/POOL_NAME POOL_NAME raidz1 /dev/sdX[1-4]
# >>> $ zfs create -o atime=off -o compression=gzip -o encryption=on -o keylocation=prompt -o keyformat=passphrase POOL_NAME/DATASET_NAME

readonly encrypted_dataset_name='{{ zfs.encrypted_dataset_name }}'
readonly encrypted_dataset_key_status="$(zfs get -H keystatus "${encrypted_dataset_name}" | awk '{print $3}')"

echo -n "Checking ZFS encryption key... "
if [[ "${encrypted_dataset_key_status}" == "unavailable" ]]
then
  zfs load-key "${encrypted_dataset_name}"
else
  echo "OK"
fi

echo -n "Checking if ZFS pool is mounted... "
if ! df '{{ zfs.mountpoint }}' 1>/dev/null 2>&1
then
  echo -n "Mounting... "
  zfs mount '{{ zfs.pool_name }}'

  echo -n "Chown... "
  chown {{ zfs.chown }} '{{ zfs.mountpoint }}/*'
fi
echo "OK"

{% if zfs.nfs_share.datasets | length > 0 %}
echo -n "Checking NFS exports... "

readonly nfs_share_options='{{ zfs.nfs_share.options | join(",") }}'
readonly nfs_datasets=(
{% for dataset_name in zfs.nfs_share.datasets %}
  '{{ dataset_name }}'
{% endfor %})

for i in {0..{{ (zfs.nfs_share.datasets | length) - 1 }}}
do
  _nfs_dataset_name="${nfs_datasets[$i]}"
  _nfs_dataset_fsid=$((1000 + $i))
  if [[ ! $(cat /var/lib/nfs/etab | grep "${_nfs_dataset_name}") ]]
  then
    # https://blog.programster.org/sharing-zfs-datasets-via-nfs
    # https://codebytez.blogspot.com/2011/06/exporting-zfs-filesystem-over-nfs.html
    echo -n "Mounting '${_nfs_dataset_name}'... "
    zfs set sharenfs="${nfs_share_options},fsid=${_nfs_dataset_fsid}" "${_nfs_dataset_name}"
  fi
done
echo "OK"
{% endif %}
