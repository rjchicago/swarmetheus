#!/bin/bash -eu

cd $(dirname "$0") &> /dev/null

COUNTRY="US"
STATE="IL"
LOCALITY="Chicago"
ORGANIZATION="Self"
ORGANIZATIONAL_UNIT="Demo"
COMMON_NAME="*.localhost"

openssl req \
  -x509 \
  -nodes \
  -days 365 \
  -newkey rsa:2048 \
  -keyout tls.key \
  -out tls.crt \
  -subj "/C=$COUNTRY/ST=$STATE/L=$LOCALITY/O=$ORGANIZATION/OU=$ORGANIZATIONAL_UNIT/CN=$COMMON_NAME"

chmod 600 tls.crt tls.key
