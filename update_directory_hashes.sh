#!/usr/bin/env bash

set -euET -o pipefail

directory="${1:-.}"
vanity_text="${2:-}"

temp_file="$(mktemp)"
hexdump="$(mktemp)"

if test -z "$vanity_text" -o "$vanity_text" = "-h" -o "$vanity_text" = "--help"; then
  echo 'Usage: ./update-hashes.sh [path/to/directory] [vanity-text]'
  echo 'The given directory should contain a file named meta.js, which will be overwritten.'
  echo 'The vanity text should be three letters, which will appear at the end of your website'\''s hash'
  exit 1
fi

touch "$directory/directory_hashes.js"
cat > "$directory/ipfs-add.sh" <<'EOF'
#!/usr/bin/env bash
set -euET -o pipefail
if test $# -lt 1 || (test "x$1" != "x--pin=true" && test "x$1" != "x--pin=false"); then
  printf "Usage:\n"
  printf "  %s --pin=true" "$0"
  printf "  %s --pin=false" "$0"
fi
ipfs cid base32 "$(ipfs add --ignore-rules-path "$(dirname "$0")/.ipfsignore" "$1" --hidden -Qr "$(dirname "$0")")"
EOF
chmod +x "$directory/ipfs-add.sh"

# TODO: use ipfs dag get instead of ipfs object get
partial_hash="$(ipfs add --ignore-rules-path "$directory/.ipfsignore" --pin=false --hidden -Qr "$directory")"
foo="$(ipfs object get "$partial_hash" | jq '.Links |= map(if .Name == "directory_hashes.js" then { "Name": .Name, "Hash": "", "Size": 0 } else . end)' )"

write_directory_hashes() {
  contents="$(printf %s "$foo" | jq -r '{vanity_text:"'"$vanity_text"'", vanity_number:'$1',tree:.} | tostring')"
  printf 'jsonp_ipfs_directory_hashes(%s);\n' "$contents" > "$directory/directory_hashes.js"
}

write_directory_hashes "0"
if test -n "$vanity_text"; then
  vanity_number="$(node "$(dirname "$0")/find_vanity.js" "$directory/directory_hashes.js" "$vanity_text")"
  printf 'Found vanity number: %s\n' $vanity_number >&2
  write_directory_hashes "$vanity_number"
fi

echo "The hash given by the page should be:" >&2
printf 'ipfs://%s\n' "$(ipfs cid base32 "$(ipfs add --ignore-rules-path "$directory/.ipfsignore" --hidden -Qr "$directory")")"
