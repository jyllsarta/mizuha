require "json"
require "sqlite3"
require "time"
require "date"
require "yaml"
require 'twitter'


class MizuhaDB
    def self.init_db(tweets_filename="tweets.js", output_db_name="tweets.db")
        tweets = loadfile(tweets_filename)
        create_new_db(output_db_name)
        insert_to_db(output_db_name, tweets)
    end

private
    def self.loadfile(filename)
        file = File.open(filename)
        content = file.read
        # remove heading garbage
        # window.YTD.tweet.part0 = [{...}] ---> [{...}]
        regal = content[25..-1]
        parsed = JSON.parse(regal)
        puts "parse finished."
        parsed
    end

    def self.create_new_db(filename)
        db = SQLite3::Database.new(filename)
        ddl = <<~EOS
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

    def self.insert_to_db(filename, tweets)
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
end

class Mizuha

    # dig_years
    def initialize(db_filename, dig_years)
        @db_filename = db_filename
        @dig_years = dig_years
    end
    
    #find tweets and wait forever
    def start
        while true do
            now = DateTime.now
            tweets = find_each_year_of_tweet(now, @dig_years, 5)
            tweets.each{|tweet|
                post tweet
            }
            sleep 3
        end
    end

    def find_each_year_of_tweet(basetime, dig_years, search_seconds)
        tweets = []
        (0..dig_years).each{|x|
            tweets += find_tweets(basetime.prev_year(x), search_seconds)
        }
        tweets
    end

    # find tweets between [basetime, basetime+offset) ; where offset is seconds
    def find_tweets(basetime, offset)
        connection = SQLite3::Database.open(@db_filename)
        sql = <<~SQL
        SELECT full_text 
        FROM tweets 
        WHERE unixtime BETWEEN ? AND ?
        SQL
        result = connection.execute(sql, basetime.to_time.to_i, basetime.to_time.to_i + offset)
        connection.close

        flatten = []
        result.each {|x| flatten.append x[0].gsub(/&gt;/,">").gsub(/&lt;/,"<")}
        remove_mute_words flatten
    end

    def remove_mute_words(tweets)
        tweets.select{|x| !x.include?("@") && !x.include?("#")}
    end

    #post tweet to twitter
    def post(content)
        keys = get_access_keys
        client = Twitter::REST::Client.new do |config|
            config.consumer_key        = keys["consumer_key"]
            config.consumer_secret     = keys["consumer_secret"]
            config.access_token        = keys["access_token"]
            config.access_token_secret = keys["access_token_secret"]
        end
        client.update(content)
    end

    def get_access_keys
        @keys = YAML.load_file("access_keys.yml") if @keys.nil?
        @keys
    end

end

# call MizuhaDB.init_db to create and initialize new database
#MizuhaDB.init_db(tweets_filename="tweet.js", output_db_name="tweets2.db")

# call Mizuha.post to say something to twitter
mizuha = Mizuha.new("tweets.db", 7)
mizuha.start
