#!/usr/bin/env bash

/etc/rc.d/rc.loki start
sleep 2

/etc/rc.d/rc.promtail start
sleep 1

/etc/rc.d/rc.rsyslogd restart
