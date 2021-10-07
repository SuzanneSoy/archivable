#!/usr/bin/env bash

set -euET -o pipefail

directory="${1:-.}"
if test -z "$directory" -o "$directory" = "-h" -o "$directory" = "--help"; then
  echo 'Usage: ./update-quine.sh [path/to/directory]'
  echo 'The given directory should contain a file named index.html, which should contain the markers XXX_PLACEHOLDER_XXX and XXX_PLACEHOLDER_END_XXX'
  exit 1
fi

# Please note that the strings PLACEHOLDER, PLACEHOLDER_START, PLACEHOLDER_DELETE and PLACEHOLDER_END must not appear wrapped with XXX_thestring_XXX anywhere else in the .html file
sed -i -e 's/XXX_PLACE''HOLDER_START_XXX/&\n\/\/ XXX_PLACE''HOLDER_DELETE_XXX/' "$directory"/index.html
sed -i -e '/XXX_PLACE''HOLDER_DELETE_XXX/,/XXX_PLACE''HOLDER_END_XXX/d' "$directory"/index.html
sed -i -e 's/XXX_PLACE''HOLDER_START_XXX/&\nvar src1 = "XXX_PLACE''HOLDER_XXX";\nvar hexLineWidth = 160;\n\/\/ XXX_PLACE''HOLDER_END_XXX/' "$directory"/index.html
xxd -ps < "$directory"/index.html | tr -d \\n | fold -w 160 | sed -e 's/.*''/"&" +/' | sed -e '1s/^/var src1 = /' | sed -e '$s/ +$/;\n/' > "$directory"/index.html.hex
# TODO: escape $directory inside the sed command, or put the temporary .hex file in a location that doesn't need escpaing.
sed -i -e '/var src1 = "XXX_PLACE''HOLDER_XXX";/ r '"$directory"'/index.html.hex' "$directory"/index.html
sed -i -e '/var src1 = "XXX_PLACE''HOLDER_XXX";/d' "$directory"/index.html
rm -f "$directory"/index.html.hex

echo "The hash given by the page should be:"
ipfs cid base32 "$(ipfs add --hidden -Qr "$directory")"
