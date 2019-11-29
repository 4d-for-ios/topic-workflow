#!/bin/bash
currentDir="."
input="$currentDir/topics.txt"
while IFS= read -r line
do
  echo "$line"
  $currentDir/topic.sh $line
done < "$input"