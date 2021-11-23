#!/usr/bin/env bash

sed -i 's|chown -R abc:abc /config /download|chown -R abc:abc /config|' /etc/cont-init.d/90-configure-aria2.sh
