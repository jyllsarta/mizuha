# mizuha
Mizuha is (a simple parser of "Twitter data" zip file | automated system of repost past tweet).

- - -

## Description

### for parser of Twitter data zip

<https://help.twitter.com/en/managing-your-account/accessing-your-twitter-data>

Twitter provides complete tweet log data, but its data orientation is [so messy](sample_tweets_file_to_parse.js).
MizuhaDB parses this file and dump into [SQLite](https://www.sqlite.org/index.html) database file.

MizuhaDB creates `tweets` table, contains columns on below:

Columns except `unixtime` are just derived from Twitter data.

column name | type
---|---
retweeted | INTEGER
source | TEXT
entities | TEXT
display_text_range | TEXT
favorite_count | INTEGER
id_str | TEXT
truncated | INTEGER
retweets_count | INTEGER
id | INTEGER
created_at | TEXT
favorited | INTEGER
full_text | TEXT
lang | TEXT
unixtime | INTEGER

### for auto-repost system

Mizuha is simple ruby script to repost tweet of past N-year.

Search and post tweets from MizuhaDB which **same month, same day, same time on past N years.**

Call `Mizuha#start` to start repost.

## Requirement

* Twitter's developper account
  * Mizuha needs access tokens for twitter account to post tweet.
* Ruby
* [Twitter gem](https://github.com/sferik/twitter)

## Usage

### Parse Twitter data

```Shell
ruby mizuha.rb init path/to/tweet.js path/to/output_filename.db
```

* ごめんまだこれできません 標準入力からコマンド切り分けられるようになるまでお待ち下さい
  * ソースのコメント手でいじれば今でも一応使えます...

### auto_repost

** Fill `access_keys.yml` before start tweet**

```Shell
ruby mizuha.rb tweet path/to/output_filename.db
```

* ごめんまだこれできません 標準入力からコマンド切り分けられるようになるまでお待ち下さい
  * ソースのコメント手でいじれば今でも一応使えます...

## Install

* just clone
* fill `access_keys.yml`

## Licence

Apache 2

## Author

[jyllsarta](jyllsarta.net)
