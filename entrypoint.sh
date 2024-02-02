#!/bin/sh
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

mkdir -p /run/cyrus/socket && chown -R cyus:mail /run/cyrus

su cyrus -g mail -c "/usr/sbin/cyrmaster -D"

echo "Aborted"

kill %1 2>/dev/null