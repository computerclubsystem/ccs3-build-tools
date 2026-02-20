#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   create-ca <ca-password> <subject> <san>
#
# Example:
#   create-ca "123" "/C=BG/ST=Varna/O=MyOrg/CN=MyRootCA" "DNS:myrootca.local"

if [ "$#" -lt 3 ]; then
  echo "Usage: create-ca <ca-password> <subject> <san>"
  exit 1
fi

CA_PASS="$1"
CA_SUBJECT="$2"
CA_SAN="$3"

mkdir -p /pki/certs /pki/private
cd /pki

[ -f index.txt ] || touch index.txt
[ -f serial ] || echo 1000 > serial

if [ -f ca.crt ] || [ -f ca.key ]; then
  echo "CA already exists."
  exit 0
fi

echo "Generating CA key..."
openssl genrsa -aes256 -passout pass:"$CA_PASS" -out ca.key 4096

echo "Generating CA certificate..."
openssl req -x509 -new -key ca.key \
  -passin pass:"$CA_PASS" \
  -days 3650 \
  -subj "$CA_SUBJECT" \
  -addext "subjectAltName=$CA_SAN" \
  -config /etc/ssl/openssl.cnf \
  -extensions v3_ca \
  -out ca.crt

echo "CA created:"
echo "  /pki/ca.key"
echo "  /pki/ca.crt"
