set -eu
curl -s -X GET "https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&redirects=1&generator=random&grnnamespace=0" | jq -r '.query.pages | to_entries[] | "\(.value.title)\n#####\n\(.value.extract)"' | fold -s
