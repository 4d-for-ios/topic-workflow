#!/bin/bash
currentDir="."
input="$currentDir/topics.txt"
status=0
while IFS= read -r line
do
  echo "🏷 $line"
  jsonDir=$currentDir/Output
  
  files=$(find $jsonDir -name '*.json')
  for jsonFile in $files; do
    echo $jsonFile
    jq -S '.' "$jsonFile" > "$jsonFile"_sorted
    rm "$jsonFile"
    mv "$jsonFile"_sorted  "$jsonFile"
  done
  
done < "$input"

exit $status
