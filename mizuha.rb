require "json"
require "sqlite3"

def loadfile(filename)
    file = File.open(filename)
    content = file.read
    # remove heading garbage
    # window.YTD.tweet.part0 = [{...}] ---> [{...}]
    regal = content[25..-1]
    parsed = JSON.parse(regal)
end

def create_new_db(filename)
    db = SQLite3::Database.new(filename)
    ddl = <<~EOF
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
    EOF
    db.execute(ddl)
    db.close
end