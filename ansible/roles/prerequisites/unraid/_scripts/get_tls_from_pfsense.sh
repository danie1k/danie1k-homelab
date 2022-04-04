#!/bin/bash

readonly CURRENT_DATE="$(date +%Y-%m-%d)"

rsync -e 'ssh -i /etc/ssh/ssh_host_rsa_key' root@{{ unraid.webhooks.tls.pfsense_hostname }}:/conf/config.xml /tmp/pfsense-config.xml
if ! dasel -f /tmp/pfsense-config.xml '.pfsense.cert.(descr={{ unraid.webhooks.tls.cert_descr }})' > /tmp/pfsense-cert.xml 2>/dev/null
then
  dasel -f /tmp/pfsense-config.xml '.pfsense.cert' > /tmp/pfsense-cert.xml
fi

mkdir -p "{{ unraid.tls_storage_dir }}/${CURRENT_DATE}"
cd "{{ unraid.tls_storage_dir }}/${CURRENT_DATE}"

dasel -f /tmp/pfsense-cert.xml '.doc.crt' | base64 --decode > ./cert.pem
dasel -f /tmp/pfsense-cert.xml '.doc.prv' | base64 --decode > ./privkey.pem

rm -f /tmp/pfsense-*.xml

# https://gist.github.com/novemberborn/4eb91b0d166c27c2fcd4
wget -O ./intermediate.pem https://letsencrypt.org/certs/lets-encrypt-r3.pem
wget -O ./ca.pem https://letsencrypt.org/certs/isrg-root-x1-cross-signed.pem
cat intermediate.pem ca.pem > chain.pem
cat cert.pem chain.pem > fullchain.pem

# https://letsencrypt.org/certificates/
openssl pkcs12 -export \
  -passout  pass:password \
  -out      ./certificate.p12 \
  -inkey    ./privkey.pem \
  -in       ./cert.pem \
  -certfile ./chain.pem

for fname in certificate.p12 cert.pem chain.pem fullchain.pem intermediate.pem privkey.pem
do
  ln -rsfv ./${fname} "{{ unraid.tls_storage_dir }}/${fname}"

  # https://docs.microsoft.com/en-us/answers/questions/613333/loading-certificatepfx-with-password-in-linux-does.html
  chmod 755 ./${fname} "{{ unraid.tls_storage_dir }}/${fname}"  # !!!!!!!!!!!!!!!!!!!!!
done
