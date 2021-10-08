#!/usr/bin/env bash

set -euET -o pipefail

directory="${1:-.}"

temp_file="$(mktemp)"
hexdump="$(mktemp)"

if test -z "$directory" -o "$directory" = "-h" -o "$directory" = "--help"; then
  echo 'Usage: ./update-quine.sh [path/to/directory]'
  echo 'The given directory should contain a file named index.html, which should contain the markers XXX_PLACEHOLDER_START_XXX and XXX_PLACEHOLDER_END_XXX'
  echo "Please note that the strings PLACEHOLDER, PLACEHOLDER_START, PLACEHOLDER_DELETE and PLACEHOLDER_END must not appear wrapped with XXX_thestring_XXX anywhere else in the .html file" 
  exit 1
fi

# Add a second marker after the starting marker
sed -i -e 's/XXX_PLACE''HOLDER_START_XXX/&\n\/\/ XXX_PLACE''HOLDER_DELETE_XXX/' "$directory"/index.html
# Delete everythinbe between the start marker and the end marker, both included
sed -i -e '/XXX_PLACE''HOLDER_DELETE_XXX/,/XXX_PLACE''HOLDER_END_XXX/d' "$directory"/index.html

# Generate template that will be used for the quine (var src1 = "the marker"; everything else unchanged)
printf %s\\n 'var src1 = "XXX_PLACEHOLDER_XXX";' >> "$temp_file"

# Generate contents to be put after the start marker
printf %s\\n 'var hexLineWidth = 160;'              >> "$temp_file"
printf %s\\n 'function srcdirectory (index_html) {' >> "$temp_file"

printf %s '  return ' >> "$temp_file"
# TODO: use ipfs dag get instead of ipfs object get
partial_hash="$(ipfs add --pin=false --hidden -Qr "$directory")"
ipfs object get "$partial_hash" \
| jq '.Links |= map(if .Name == "index.html" then { "Name": .Name, "Hash": "XXX_PLACEHOLDER_HASH_XXX", "Size": "XXX_PLACEHOLDER_SIZE_XXX" } else . end)' \
| sed -e '2,$s/^/  /' -e '$s/$/;/' -e 's/["'\'']XXX_PLACEHOLDER_HASH_XXX["'\'']/index_html.hash/' -e 's/["'\'']XXX_PLACEHOLDER_SIZE_XXX["'\'']/index_html.block.length/' \
>> "$temp_file"
printf %s\\n '}' >> "$temp_file"

printf %s\\n '// XXX_PLACE''HOLDER_END_XXX' >> "$temp_file"

# Add the generated contents after the start marker
# TODO: escape $temp_file inside the sed command, or make sure the path doesn't need escpaing.
sed -i -e '/XXX_PLACE''HOLDER_START_XXX/ r '"$temp_file" "$directory"/index.html

# Generate hexdump of the file with the placeholder
xxd -ps < "$directory"/index.html | tr -d \\n | fold -w 160 | sed -e 's/.*''/"&" +/' | sed -e '1s/^/var src1 = /' | sed -e '$s/ +$/;\n/' >> "$hexdump"
# Replace the placeholder with the hexdump
# TODO: escape $temp_file inside the sed command, or make sure the path doesn't need escpaing.
sed -i -e '/var src1 = "XXX_PLACE''HOLDER_XXX";/ r '"$hexdump" "$directory"/index.html
# Remove the line with the placeholder
sed -i -e '/var src1 = "XXX_PLACE''HOLDER_XXX";/ d' "$directory"/index.html

echo "The hash given by the page should be:"
ipfs cid base32 "$(ipfs add --hidden -Qr "$directory")"
