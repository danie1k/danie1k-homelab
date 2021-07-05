#!/usr/bin/env sh

# Disable Apache2 access logs
ln -fs /dev/null /var/log/apache2/access.log

exec /usr/local/bin/entrypoint.sh
