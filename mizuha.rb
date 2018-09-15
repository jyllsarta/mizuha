require "json"
require "sqlite3"
require "time"
require "yaml"
require 'twitter'

def loadfile(filename)
    file = File.open(filename)
    content = file.read
    # remove heading garbage
    # window.YTD.tweet.part0 = [{...}] ---> [{...}]
    regal = content[25..-1]
    parsed = JSON.parse(regal)
    puts "parse finished."
    parsed
end

def create_new_db(filename)
    db = SQLite3::Database.new(filename)
    ddl = <<EOS
        CREATE TABLE tweets(
            retweeted INTEGER,
            source TEXT,
            entities TEXT,
            display_text_range TEXT,
            favorite_count INTEGER,
            id_str TEXT,
            truncated INTEGER,
            retweets_count INTEGER,
            id INTEGER,
            created_at TEXT,
            favorited INTEGER,
            full_text TEXT,
            lang TEXT,
            unixtime INTEGER
        );
EOS
    db.execute(ddl)
    puts "DB created."
    db.close
end

def insert_to_db(filename, tweets)
    db = SQLite3::Database.open(filename)
    db.transaction

    sql = " INSERT INTO tweets VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?)"
    count = 0
    tweets.each{ |t|
        count += 1
        if count % 1000 == 0
            puts "inserting #{t["created_at"]} ..."
        end
        db.execute(
            sql,
            t["retweeted"] ? 1 : 0,
            t["source"],
            t["entities"].to_s,
            t["display_text_range"].to_s, #使い道が思いつかないので正規化する気にならない
            t["favorite_count"],
            t["id_str"],
            t["truncated"] ? 1 : 0,
            t["retweets_count"],
            t["id"],
            t["created_at"],
            t["favorited"] ? 1 : 0,
            t["full_text"],
            t["lang"],
            Time.parse(t["created_at"]).to_i #is unixtime
        )
    }
    puts "comitting..."
    db.commit
    puts "commit finished!"
    db.close
end

def init()
    filename = "tweets.db"
    tweets = loadfile("tweet.js")
    create_new_db(filename)
    insert_to_db(filename, tweets)
end

def get_access_keys()
    keys = YAML.load_file("__access_keys.yml")
end

def post_to_twitter(keys, content)
    client = Twitter::REST::Client.new do |config|
        config.consumer_key        = keys["consumer_key"]
        config.consumer_secret     = keys["consumer_secret"]
        config.access_token        = keys["access_token"]
        config.access_token_secret = keys["access_token_secret"]
    end
    client.update("にゃあーん")
end

keys = get_access_keys()
post_to_twitter(keys, "に")