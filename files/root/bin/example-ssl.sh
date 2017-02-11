#!/bin/bash

# Specify where we will install
# the example.local certificate
SSL_DIR="/app/etc/nginx/ssl"

# Set the wildcarded domain
# we want to use
DOMAIN="example.local"

# A blank passphrase
PASSPHRASE=""

# Set our CSR variables
SUBJ="
C=US
ST=Washington
O=
localityName=DC
commonName=$DOMAIN
organizationalUnitName=
emailAddress=
"

# Create our SSL directory
# in case it doesn't exist
mkdir -p "$SSL_DIR"

# Generate our Private Key, CSR and Certificate
openssl genrsa -out "$SSL_DIR/example.key" 2048
openssl req -new -subj "$(echo -n "$SUBJ" | tr "\n" "/")" -key "$SSL_DIR/example.key" -out "$SSL_DIR/example.csr" -passin pass:$PASSPHRASE
openssl x509 -req -days 3650 -in "$SSL_DIR/example.csr" -signkey "$SSL_DIR/example.key" -out "$SSL_DIR/example.pem"
