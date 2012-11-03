require 'tweetstream'
require 'yaml'

TWITTER_CONSUMER_KEY = "yR6hU0qcwt0vVd8GRwchXw"
TWITTER_CONSUMER_SECRET = "VQTgrwTonVYJQY4o1nS1ucAJ3eUILfOOhcUkKoLFko"
TWITTER_OAUTH_TOKEN = "921355608-LBZ9ASptzT0f9tAbCmcxJjREcjj82kMnMdzrrBbT"
TWITTER_OAUTH_TOKEN_SECRET = "jdsihj0ZNeTXZxaGEJ4h0yp6RUkj1SOMe8dGbaM20"
HASHTAG = "#deepteal"
MSG_TO_MATCH = "testtest"

TweetStream.configure do |config|
    config.consumer_key       = TWITTER_CONSUMER_KEY
    config.consumer_secret    = TWITTER_CONSUMER_SECRET
    config.oauth_token        = TWITTER_OAUTH_TOKEN
    config.oauth_token_secret = TWITTER_OAUTH_TOKEN_SECRET
    config.auth_method        = :oauth
end

# @user_text = []
# @client = TweetStream::Client.new
# @client.sample do |status|
#   puts status.text
#   if found_hashtag?(status.hashtags, HASHTAG)
#     @user_text = [status.screen_name, status.text]
#     client.stop if @user_text[1] == MSG_TO_MATCH
#   end
#   puts "=====WE FOUND ======"
#   puts @user_text.inspect
#
# end

@username = ""

def challenge?(message)
  message = strip_hashtag(message)
  message = strip_digits(message)
  return true if message == "we are testing"
  false
end

def strip_hashtag(message)
  message = message.gsub(/\s\#deepteal/, "")
end

def strip_digits(message)
  message = message.gsub(/\d/, "")
end

# TweetStream::Client.new.track('bieber') do |status|
#   puts "#{status.text}"
# end

puts "Start time: #{Time.now}"
TweetStream::Client.new.on_delete{ |status_id, user_id|
  Tweet.delete(status_id)
  }.on_limit { |skip_count|
    puts "skipping"
    sleep 5
  }.track('@dariusmorris4') do |status|
    puts "Tweet retrieved: #{Time.now}"
    puts status.text
    puts "end"
end

def limit
  @client.on_limit do |skip_count|
    break if skip_count > 10
  end
end

def found_hashtag?(hashtag_array, hashtag)
  hashtag_array.include?(hashtag)
end




