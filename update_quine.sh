#!/usr/bin/env bash

set -euET -o pipefail

# Please note that the strings PLACEHOLDER, PLACEHOLDER_START, PLACEHOLDER_DELETE and PLACEHOLDER_END must not appear wrapped with XXX_thestring_XXX anywhere else in the .html file
sed -i -e 's/XXX_PLACE''HOLDER_START_XXX/&\n\/\/ XXX_PLACE''HOLDER_DELETE_XXX/' index.html
sed -i -e '/XXX_PLACE''HOLDER_DELETE_XXX/,/XXX_PLACE''HOLDER_END_XXX/d' index.html
sed -i -e 's/XXX_PLACE''HOLDER_START_XXX/&\nvar src1 = "XXX_PLACE''HOLDER_XXX";\nvar hexLineWidth = 160;\n\/\/ XXX_PLACE''HOLDER_END_XXX/' index.html
xxd -ps < index.html | tr -d \\n | fold -w 160 | sed -e 's/.*''/"&" +/' | sed -e '1s/^/var src1 = /' | sed -e '$s/ +$/;\n/' > index.html.hex
sed -i -e '/var src1 = "XXX_PLACE''HOLDER_XXX";/ r index.html.hex' index.html
sed -i -e '/var src1 = "XXX_PLACE''HOLDER_XXX";/d' index.html
rm -f index.html.hex
cp -f index.html /tmp/new
ipfs add --hidden -Qr /tmp/new

