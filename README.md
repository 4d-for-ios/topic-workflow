# topic-workflow

Generate json files by topic defined in [topics.txt](topics.txt),
which contains [github api search request result](https://developer.github.com/v3/search/#search-topics)


## Workflow

[github workflow](.github/workflows/update.yml):
* ⬇️ Get the curent files
* 🔄 Update the JSON
  * 🔍 by making github search request
  * 🗑 removing changing `score` attribute
  * 🔀 and sort by `items.id`
* ⬆️ Push to github
  * only if there is some modification
