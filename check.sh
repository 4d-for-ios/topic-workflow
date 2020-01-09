#!/bin/bash
currentDir="."
input="$currentDir/topics.txt"
status=0
while IFS= read -r line
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
