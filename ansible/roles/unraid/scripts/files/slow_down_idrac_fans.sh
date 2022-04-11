#!/bin/bash

# Enable manual fan control
ipmitool -v -I lanplus -H "${IDRAC_HOST}" -U "${IDRAC_USERNAME}" -P "${IDRAC_PASSWORD}" raw 0x30 0x30 0x01 0x00

# Set fan speed to 20%
ipmitool -v -I lanplus -H "${IDRAC_HOST}" -U "${IDRAC_USERNAME}" -P "${IDRAC_PASSWORD}" raw 0x30 0x30 0x02 0xff 0x14
