#!/usr/bin/env bash
set -euET -o pipefail
if test $# -lt 1 || (test "x$1" != "x--pin=true" && test "x$1" != "x--pin=false"); then
  printf "Usage:\n"
  printf "  %s --pin=true" "$0"
  printf "  %s --pin=false" "$0"
fi
ipfs cid base32 "$(ipfs add --ignore-rules-path "$(dirname "$0")/.ipfsignore" "$1" --hidden -Qr "$(dirname "$0")")"
