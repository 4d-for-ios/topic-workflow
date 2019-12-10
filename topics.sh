#!/bin/bash
currentDir="."
token=$1
input="$currentDir/topics.txt"
while IFS= read -r line
do
  echo "$line"
  $currentDir/topic.sh $line $token
done < "$input"
