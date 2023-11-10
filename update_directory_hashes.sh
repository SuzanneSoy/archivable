#!/usr/bin/env bash

set -euET -o pipefail

vanity_text="${1:-xyz}"
vanity_number="${2:-0}"
directory="${3:-.}"

temp_file="$(mktemp)"
hexdump="$(mktemp)"

if test -z "$directory" -o "$directory" = "-h" -o "$directory" = "--help"; then
  echo 'Usage: ./update-hashes.sh vanity-text vanity-number [path/to/directory]'
  echo 'The given directory should contain a file named meta.js, which will be overwritten.'
  exit 1
fi

printf %s 'var ipfs_directory_hashes=' >> "$temp_file"

# TODO: use ipfs dag get instead of ipfs object get
partial_hash="$(ipfs add --ignore-rules-path .ipfsignore --pin=false --hidden -Qr "$directory")"
ipfs object get "$partial_hash" \
| jq '.Links |= map(if .Name == "directory_hashes.js" then { "Name": .Name, "Hash": "", "Size": 0 } else . end)' \
| jq -r '{vanity_text:"'"$vanity_text"'", vanity_number:'$vanity_number',tree:.} | tostring' >> "$temp_file"
sed -i -e 's/$/;/' "$temp_file"

mv "$temp_file" "$directory"/directory_hashes.js

echo "The hash given by the page should be:"
ipfs cid base32 "$(ipfs add --ignore-rules-path .ipfsignore --hidden -Qr "$directory")"
