#!/bin/bash

# Create ZFS pool on a single drive (https://youtu.be/-wlbvt9tM-Q)
#
# >>> $ parted /dev/sdX mklabel gpt
# >>> $ parted /dev/sdX mkpart zfs 0% 25%
# >>> $ parted /dev/sdX mkpart zfs 25% 50%
# >>> $ parted /dev/sdX mkpart zfs 50% 75%
# >>> $ parted /dev/sdX mkpart zfs 75% 100%
#
# >>> $ zpool create -m /mnt/POOL_NAME POOL_NAME raidz1 /dev/sdX[1-4]
# >>> $ zfs create -o compression=gzip -o encryption=on -o keylocation=prompt -o keyformat=passphrase POOL_NAME/DATASET_NAME

_zfs_dataset_name="POOL_NAME/DATASET_NAME" <--------------------------------------------
_zfs_key_status="$(zfs get -H keystatus "$_zfs_dataset_name" | awk '{print $3}')"

_nfs_nobody_uid="$(id -u nobody)"
_nfs_nobody_gid="$(id -g nobody)"
_nfc_client_loc="127.0.0.1/32" <--------------------------------------------------------

echo -n "Checking ZFS encryption key... "
if [[ "$_zfs_key_status" == "unavailable" ]]
then
  zfs load-key "$_zfs_dataset_name"
else
  echo "OK"
fi

echo -n "Checking ZFS mount... "
if [[ ! $(df "/mnt/$_zfs_dataset_name" | grep "$_zfs_dataset_name") ]]
then
  echo -n "Mounting... "
  zfs mount "$_zfs_dataset_name"

  echo -n "Chown... "
  chown $_nfs_nobody_uid:$_nfs_nobody_gid "/mnt/$_zfs_dataset_name"
fi
echo "OK"

echo -n "Checking NFS export..."
if [[ ! $(cat /etc/exports | grep "$_zfs_dataset_name") ]]
then
  echo -n "Adding export... "
  echo "" >> /etc/exports
  echo "\"/mnt/${_zfs_dataset_name}\" -async,all_squash,root_squash,no_subtree_check,fsid=1000,anonuid=${_nfs_nobody_uid},anongid=${_nfs_nobody_gid} ${_nfc_client_loc}(rw)" >> /etc/exports

  echo -n "Exporting shares..."
  exportfs -r
fi
echo "OK"
