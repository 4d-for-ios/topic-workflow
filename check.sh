#!/bin/bash
currentDir="."
token=$1
input="$currentDir/topics.txt"
while IFS= read -r line
status=0
do
  echo "$line"
  jsonFile=$currentDir/$line.json
  
  if jq -e . >/dev/null 2>&1 <<< cat $jsonFile; then
    echo "✅ $line.json valid"
    # check incomplete?
  else
    echo "❌ $line invalid json"
    status=1
  fi
  
done < "$input"

exit $status
