#!/bin/bash

# https://www.dell.com/support/kbdoc/en-us/000120158/dell-poweredge-how-to-import-an-externally-created-custom-certificate-and-private-key-into-the-idrac
racadm -r "${IDRAC_HOST}" -u "${IDRAC_USERNAME}" -p "${IDRAC_PASSWORD}" sslkeyupload  -t 1 -f '{{ unraid.tls_storage_dir }}'/privkey.pem
racadm -r "${IDRAC_HOST}" -u "${IDRAC_USERNAME}" -p "${IDRAC_PASSWORD}" sslcertupload -t 1 -f '{{ unraid.tls_storage_dir }}'/cert.pem

racadm -r "${IDRAC_HOST}" -u "${IDRAC_USERNAME}" -p "${IDRAC_PASSWORD}" racreset soft
sleep 3m
racadm -r "${IDRAC_HOST}" -u "${IDRAC_USERNAME}" -p "${IDRAC_PASSWORD}" getsysinfo
