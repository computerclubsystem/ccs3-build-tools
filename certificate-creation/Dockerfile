FROM alpine:3.20

RUN apk add --no-cache openssl bash

WORKDIR /pki

# Default OpenSSL config
COPY openssl.cnf /etc/ssl/openssl.cnf

# Scripts
COPY create-ca.sh /usr/local/bin/create-ca
COPY create-cert.sh /usr/local/bin/create-cert

RUN chmod +x /usr/local/bin/create-ca /usr/local/bin/create-cert

# Volume for generated material
VOLUME ["/pki"]

ENTRYPOINT ["/bin/bash"]
