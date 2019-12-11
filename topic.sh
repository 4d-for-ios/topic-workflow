function search_topic {
  topic=$1
  token=$2
  curl -H "Accept: application/vnd.github.mercy-preview+json" -H "Authorization: token $token" https://api.github.com/search/repositories?q=topic:$topic | jq -S 'del(.. |.score?)' | jq '.items|=sort_by(.id)' > $topic.json
}
search_topic $1 $2

# if incomplete, try again
incomplete_results=$(jq -r '.incomplete_results' $topic.json | grep "true" | wc -l)
if [ $incomplete_results -eq 1 ]; then
   sleep 10 # after 10s
   search_topic $1 $2
fi
