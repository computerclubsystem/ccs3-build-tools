#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   create-cert <name> <usage> <key-pass> <ca-pass> <subject> <san>
#
# Example:
#   create-cert client1 both "client1pass" "123" "/C=BG/ST=Varna/CN=client1" "DNS:client1.local,IP:10.0.0.5"

if [ "$#" -lt 6 ]; then
  echo "Usage: create-cert <name> <usage> <key-pass> <ca-pass> <subject> <san>"
  exit 1
fi

NAME="$1"
USAGE="$2"
KEY_PASS="$3"
CA_PASS="$4"
SUBJECT="$5"
SAN="$6"

case "$USAGE" in
  client) EXT_SECTION="v3_client" ;;
  server) EXT_SECTION="v3_server" ;;
  both)   EXT_SECTION="v3_both" ;;
  *) echo "Invalid usage: $USAGE"; exit 1 ;;
esac

cd /pki

if [ ! -f ca.crt ] || [ ! -f ca.key ]; then
  echo "CA not found."
  exit 1
fi

KEY_FILE="${NAME}.key"
CSR_FILE="${NAME}.csr"
CRT_FILE="${NAME}.crt"
PFX_FILE="${NAME}.pfx"

echo "Generating key..."
openssl genrsa -aes256 -passout pass:"$KEY_PASS" -out "$KEY_FILE" 4096

echo "Generating CSR..."
openssl req -new \
  -key "$KEY_FILE" \
  -passin pass:"$KEY_PASS" \
  -subj "$SUBJECT" \
  -addext "subjectAltName=$SAN" \
  -out "$CSR_FILE"

echo "Signing certificate..."
openssl ca -batch \
  -config /etc/ssl/openssl.cnf \
  -extensions "$EXT_SECTION" \
  -passin pass:"$CA_PASS" \
  -in "$CSR_FILE" \
  -out "$CRT_FILE"

echo "Exporting PFX..."
openssl pkcs12 -export \
  -inkey "$KEY_FILE" \
  -passin pass:"$KEY_PASS" \
  -in "$CRT_FILE" \
  -certfile ca.crt \
  -name "$NAME" \
  -out "$PFX_FILE" \
  -passout pass:"$KEY_PASS"

echo "Created:"
echo "  $KEY_FILE"
echo "  $CSR_FILE"
echo "  $CRT_FILE"
echo "  $PFX_FILE"
