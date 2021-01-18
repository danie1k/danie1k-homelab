#!/usr/bin/env bash
set -e

export ANSIBLE_NOCOWS=1
ansible-playbook --limit=unraid playbook.yml -v
