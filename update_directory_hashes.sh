#!/usr/bin/env bash

set -euET -o pipefail

node "$(dirname "$0")/find_vanity.js" "directory-hashes.js"
exit

vanity_text="${1:-xyz}"
directory="${2:-.}"

temp_file="$(mktemp)"
hexdump="$(mktemp)"

if test -z "$vanity_text" -o "$vanity_text" = "-h" -o "$vanity_text" = "--help"; then
  echo 'Usage: ./update-hashes.sh vanity-text [path/to/directory]'
  echo 'The given directory should contain a file named meta.js, which will be overwritten.'
  echo 'The vanity text should be three letters, which will appear at the end of your website'\''s hash'
  exit 1
fi

# TODO: use ipfs dag get instead of ipfs object get
partial_hash="$(ipfs add --ignore-rules-path "$directory/.ipfsignore" --pin=false --hidden -Qr "$directory")"
foo="$(ipfs object get "$partial_hash" | jq '.Links |= map(if .Name == "directory_hashes.js" then { "Name": .Name, "Hash": "", "Size": 0 } else . end)' )"

write_directory_hashes() {
  contents="$(printf %s "$foo" | jq -r '{vanity_text:"'"$vanity_text"'", vanity_number:'$1',tree:.} | tostring')"
  printf 'var ipfs_directory_hashes=%s; if (typeof module != '\''undefined'\'') { module.exports = { ipfs_directory_hashes: ipfs_directory_hashes }; }\n' "$contents" > "$directory"/directory_hashes.js
}

write_directory_hashes "0"
vanity_number="$(node find_vanity.js)"
printf 'Found vanity number: %s\n' $vanity_number >&3
write_directory_hashes "$vanity_number"

echo "The hash given by the page should be:" >&2
printf 'ipfs://%s\n' "$(ipfs cid base32 "$(ipfs add --ignore-rules-path "$directory/.ipfsignore" --hidden -Qr "$directory")")"
