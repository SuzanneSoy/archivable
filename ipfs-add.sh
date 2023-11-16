#!/usr/bin/env bash
set -euET -o pipefail
ipfs cid base32 "$(ipfs add --ignore-rules-path result/www/.ipfsignore --pin=false --hidden -Qr "$(dirname "$0")")"
