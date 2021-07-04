#!/usr/bin/env bash
set -e

export ANSIBLE_NOCOWS=1
export ANSIBLE_CONFIG="$(pwd)/ansible.cfg"
ansible-playbook --limit=unraid playbook.yml -v
