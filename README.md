<p align="center">
  <a href="https://unraid.net/" target="_blank">
    <img src="https://img.shields.io/badge/unraid-6.8.3-9cf?logo=unraid&style=for-the-badge" alt="unRAID 6.8.3">
  </a>
  <a href="https://docs.ansible.com/ansible/2.10/" target="_blank">
    <img src="https://img.shields.io/badge/ansible-2.10-9cf?logo=ansible&style=for-the-badge" alt="Ansible 2.10">
  </a>
  <br>
  <a href="https://www.dell.com/support/home/pl-pl/product-support/product/poweredge-r720/overview" target="_blank">
    <img src="https://img.shields.io/badge/Dell-PowerEdge%20r720-%23989898?logo=dell&style=for-the-badge" alt="Dell PowerEdge r720">
  </a>
  <a href="https://www.dell.com/support/home/pl-pl/product-support/product/idrac7-8-lifecycle-controller-v2.65.65.65/overview" target="_blank">
    <img src="https://img.shields.io/badge/Dell-iDRAC7-%23989898?logo=dell&style=for-the-badge" alt="Dell iDRAC7">
  </a>
  <br>
  <img src="https://img.shields.io/badge/release-beta-red?style=for-the-badge" alt="Beta">
  <a href="./LICENSE">
    <img src="https://img.shields.io/github/license/danie1k/danie1k-unraid?style=for-the-badge" alt="MIT License">
  </a>
</p>

# danie1k-homelab

Personal [homelab](https://www.reddit.com/r/homelab/) iDRAC7 & unRAID base infrastructure as code


## unRaid requirements

1. "[Community Applications](https://lime-technology.com/forums/topic/38582-plug-in-community-applications/)" plugin
    1. "[CA User Scripts](http://lime-technology.com/forum/index.php?topic=49992.0)" app
    1. "[Sanoid](https://forums.unraid.net/topic/94549-sanoidsyncoid-zfs-snapshots-and-replication/)" app
1. "[NerdPack](http://lime-technology.com/forum/index.php?topic=37541.0)" plugin
    1. `ipmitool-*-x86_64-1.txz` package
    1. `python3-3.*-x86_64-1.txz` package
1. "[ZFS for unRAID 6](http://lime-technology.com/forum/index.php?topic=43019.0)" plugin


## Ansible

Ansible requires Python interpreter to be installed in unRAID.  

1. Use [Nerd Pack plugin](https://forums.unraid.net/topic/35866-unraid-6-nerdpack-cli-tools-iftop-iotop-screen-kbd-etc/) to install Python 3.
1. Then set `ansible_python_interpreter=/usr/bin/python3` in Ansible `inventory` file.
