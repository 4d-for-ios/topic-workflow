# topic-workflow

Generate json files by topic defined in [topics.txt](topics.txt),
which contains [github api search request result](https://developer.github.com/v3/search/#search-topics)

## Workflows


[![update][update-shield]][update-url] 

* ⬇️ Get the curent files
* 🔄 Update the JSON
  * 🔍 by making github search request
  * 🗑 removing changing `score` attribute
  * 🔀 and sort by `items.id`
* ⬆️ Push to github
  * only if there is some modification
  
_[code](.github/workflows/update.yml)_

[![check][check-shield]][check-url]

* ⬇️ Get the curent files
* 🔄 Check if JSON valid

_[code](.github/workflows/check.yml)_
 

<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[update-shield]: https://github.com/4d-for-ios/topic-workflow/workflows/update/badge.svg
[update-url]: https://github.com/4d-for-ios/topic-workflow/actions?workflow=update
[check-shield]: https://github.com/4d-for-ios/topic-workflow/workflows/check/badge.svg
[check-url]: https://github.com/4d-for-ios/topic-workflow/actions?workflow=check
