set -eu
curl -s --max-time 0.5 -X GET "https://en.wikipedia.org/w/api.php?format=json&action=query&prop=extracts&exintro&explaintext&redirects=1&generator=random&grnnamespace=0" | jq -r '.query.pages | to_entries[] | "\(.value.title)\n#####\n\(.value.extract)"' | fold -s
