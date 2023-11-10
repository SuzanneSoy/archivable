/* @preserve
  Replace the following string by "XXX_PLACEHOLDER_XXX", then convert the file to hexadecimal
  with hexLineWidth nibbles per line, each line formatted without any indentation as
  "abcdef00abcdef…" +
  except for the last line formatted as
  "abcdef00abcdef…";
  and the first line which starts immediately after the = sign.
  Unix script to do this:

#!/usr/bin/env bash

set -euET -o pipefail

directory="${1:-.}"

temp_file="$(mktemp)"

if test -z "$directory" -o "$directory" = "-h" -o "$directory" = "--help"; then
  echo 'Usage: ./update-quine.sh [path/to/directory]'
  echo 'The given directory should contain a file named index.html, which should contain the markers XXX_PLACE''HOLDER_START_XXX and XXX_PLACE''HOLDER_END_XXX'
  echo 'Please note that the strings XXX_PLACE''HOLDER_XXX, XXX_PLACE''HOLDER_START_XXX, XXX_PLACE''HOLDER_DELETE_XXX and XXX_PLACE''HOLDER_END_XXX must not appear anywhere else in the .html file'
  exit 1
fi

# Add a second marker after the starting marker
sed -i -e 's/XXX_PLACE''HOLDER_START_XXX/&\n\/\/ XXX_PLACE''HOLDER_DELETE_XXX/' "$directory"/index.html
# Delete everythinbe between the start marker and the end marker, both included
sed -i -e '/XXX_PLACE''HOLDER_DELETE_XXX/,/XXX_PLACE''HOLDER_END_XXX/d' "$directory"/index.html

# Generate contents to be put after the start marker
xxd -ps < "$directory"/index.html | tr -d \\n | fold -w 160 | sed -e 's/.*''/"&" +/' | sed -e '1s/^/var src1 = /' | sed -e '$s/ +$/;\n/' >> "$temp_file"
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

# TODO: escape $temp_file inside the sed command, or make sure the path doesn't need escpaing.
sed -i -e '/XXX_PLACE''HOLDER_START_XXX/ r '"$temp_file" "$directory"/index.html

echo "The hash given by the page should be:"
ipfs cid base32 "$(ipfs add --hidden -Qr "$directory")"
*/

// XXX_PLACEHOLDER_START_XXX
var src1 = "XXX_PLACEHOLDER_XXX";
var hexLineWidth = 160;
// XXX_PLACEHOLDER_END_XXX

function formatHexdump(hexLineWidth, src1) {
    var formattedHexdump = [];
    var j = 0;
    for (var i = 0; i < src1.length; i+=hexLineWidth) {
      formattedHexdump[j++] = src1.substring(i, i+hexLineWidth);
    }
    return "var src1 = \"" + formattedHexdump.join('" +\n"') + '";';
  }
  
  var src2 = src1.replace(utf8StringToHex("var src1 = \"XXX_PLACEHOLDER_XXX\";"), utf8StringToHex(formatHexdump(hexLineWidth, src1)));
  