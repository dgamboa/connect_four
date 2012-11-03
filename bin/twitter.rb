require 'sqlite3'
require 'twitter'
require 'tweetstream'
require 'yaml'

# -----------------------------------------------------------------------------
# Twitter configuration
# -----------------------------------------------------------------------------

TWITTER_CONSUMER_KEY = "yR6hU0qcwt0vVd8GRwchXw"
TWITTER_CONSUMER_SECRET = "VQTgrwTonVYJQY4o1nS1ucAJ3eUILfOOhcUkKoLFko"
TWITTER_OAUTH_TOKEN = "921355608-LBZ9ASptzT0f9tAbCmcxJjREcjj82kMnMdzrrBbT"
TWITTER_OAUTH_TOKEN_SECRET = "jdsihj0ZNeTXZxaGEJ4h0yp6RUkj1SOMe8dGbaM20"

Twitter.configure do |config|
    config.consumer_key       = TWITTER_CONSUMER_KEY
    config.consumer_secret    = TWITTER_CONSUMER_SECRET
    config.oauth_token        = TWITTER_OAUTH_TOKEN
    config.oauth_token_secret = TWITTER_OAUTH_TOKEN_SECRET
end

TweetStream.configure do |config|
    config.consumer_key       = TWITTER_CONSUMER_KEY
    config.consumer_secret    = TWITTER_CONSUMER_SECRET
    config.oauth_token        = TWITTER_OAUTH_TOKEN
    config.oauth_token_secret = TWITTER_OAUTH_TOKEN_SECRET
    config.auth_method        = :oauth
end

# -----------------------------------------------------------------------------
# Preliminary methods: these need to be defined before running TweetStream
# -----------------------------------------------------------------------------

def post_challenge
  post_id = Time.now.strftime("%F %T.%L")
  Twitter.update("Who wants to get demolished? #dbc_c4 #{post_id}")
  listen_for_challenger
end

def challenge?(message)
  message = strip_hash(message)
  return true if message == "@deepteal Game on!"
  false
end

def strip_hash(message)
  message = message.gsub(/\s\#dbc_c4/, "")
end

# -----------------------------------------------------------------------------
# Open the TwitterStream and start the game
# -----------------------------------------------------------------------------

post_challenge
@username = ""
TweetStream::Client.new.on_delete{ |status_id, user_id|
  Tweet.delete(status_id)
  }.on_limit { |skip_count|
    puts "skipping"
    sleep 5
  }.track('@deepteal') do |status|
    msg = status.text
    if challenge?(msg)
      @username = status.user.screen_name 
      Twitter.update("#{@username} get ready to be crushed!")
      start_game
      post_challenge
    end
end

def start_game

end
