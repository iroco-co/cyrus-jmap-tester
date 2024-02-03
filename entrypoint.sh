#!/bin/sh
rsyslogd
mkdir -p /etc/pki/cyrus-imapd/
if [ ! -f /etc/pki/cyrus-imapd/cyrus-imapd.pem ]; then
  echo "--- Generating Cyrus Certificates (in /etc/pki/cyrus-imapd)"
  sscg --package cyrus-imapd \
    --cert-file /etc/pki/cyrus-imapd/cert.pem \
    --cert-key-file /etc/pki/cyrus-imapd/privkey.pem \
    --ca-file /etc/pki/cyrus-imapd/ca.pem \
    --cert-key-mode=0640

  chown cyrus: /etc/pki/cyrus-imapd/*
  echo "--- Finished generating certificates"
fi

rm -f /var/lib/cyrus/jwt/jmap.pem
{
  echo "-----BEGIN HMAC KEY-----"
  echo $JWT_SECRET | base64
  echo "-----END HMAC KEY-----"
} > /var/lib/cyrus/jwt/jmap.pem

chown cyrus:mail /var/lib/cyrus/jwt/jmap.pem
chmod 600 /var/lib/cyrus/jwt/jmap.pem

mkdir -p /run/cyrus/socket && chown cyrus:mail /run/ && chown -R cyrus:mail /run/cyrus
service saslauthd start

tail -f /var/log/syslog &
su cyrus -c "/usr/local/libexec/master -C /etc/imapd.conf -M /etc/cyrus.conf"

echo "Aborted"

kill %1 2>/dev/null