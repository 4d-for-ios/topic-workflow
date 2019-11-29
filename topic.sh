topic=$1
curl -H "Accept: application/vnd.github.mercy-preview+json" https://api.github.com/search/repositories?q=topic:$topic | jq -S 'del(.. |.score?)' > $topic.json
