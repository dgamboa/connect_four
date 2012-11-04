require 'sqlite3'
require 'twitter'
require 'tweetstream'
require 'yaml'
require_relative 'session'


# ----------------------------------------------------------------------------------------
# Twitter configuration
# ----------------------------------------------------------------------------------------

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

# ----------------------------------------------------------------------------------------
# Methods used for Twitter game flow: these need to be defined before running TweetStream
# ----------------------------------------------------------------------------------------

$sessions_container = []

def post_challenge
  post_id = Time.now.strftime("%F %T.%L")
  Twitter.update("Who wants to get demolished? #dbc_c4 #{post_id}")
  listen_for_game
end

def challenge?(message)
  return !(message =~ /[\s]*\@deepteal[\s]*[G|g]ame[\s]*on[!]?[\s]*\#dbc_c4[\s]*/).nil?
end

def board?(message)
  return !(message =~ /[\s]*\@deepteal[\s]*(\|\S{7}\|\S{7}\|\S{7}\|\S{7}\|\S{7}\|\S{7}\|)[\s]*\#dbc_c4[\s]*/).nil?
end

def start_game(player)
  $sessions_container << Session.new(player)
end

def strip_to_board(message)
  message.match(/[\s]*\@deepteal[\s]*(\|\S{7}\|\S{7}\|\S{7}\|\S{7}\|\S{7}\|\S{7}\|)[\s]*\#dbc_c4[\s]*/)
  return $1
end

def send_to_session(player, board)
  $sessions_container.each do |session|
    if session.player == player
      session.receive(board)
      return true
    end
  end
  false
end

# ----------------------------------------------------------------------------------------
# Start the game and open the TweetStream
# ----------------------------------------------------------------------------------------

post_challenge

def listen_for_game
  TweetStream::Client.new.on_delete{ |status_id, user_id|
    Tweet.delete(status_id)
    }.on_limit { |skip_count|
      puts "skipping"
      sleep 5
    }.track('@deepteal') do |status|
      msg = status.text
      if challenge?(msg)
        player = status.user.screen_name
        Twitter.update("\@{player} get ready to be crushed!")
        start_game(player)
        post_challenge
      elsif board?(msg)
        player = status.user.screen_name
        board = strip_to_board(msg)
        start_game(player) unless send_to_session(player, board)
      end
  end
end

# A session object should have a player attr_reader that containes the opponent's username (for session_handler check and to know who to send to)
# It should also have a method #receive that takes in a board in string format
# It should also have an initialize method that takes in a player in the format 'username' not '@username'

