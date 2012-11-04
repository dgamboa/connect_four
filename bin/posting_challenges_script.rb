require 'sqlite3'
require 'twitter'
require 'tweetstream'
require 'yaml'
require_relative '../lib/session'


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
  Twitter.update("Who wants to get demolished? \#dbc_c4 #{post_id}")
  listen_for_game
end

def acceptance?(message)
  return !(message =~ /[\s]*\@deepteal[\s]*[G|g]ame[\s]*on[!]?[\s]*\#dbc_c4[\s]*/).nil?
end

def board?(message)
  return !(message =~ /[\s]*\@deepteal[\s]*(\|\S{7}\|\S{7}\|\S{7}\|\S{7}\|\S{7}\|\S{7}\|)[\s]*\#dbc_c4[\s]*/).nil?
end

def take_challenge?(message)

end


def start_game(opponent)
  $sessions_container << Session.new(opponent)
end

def strip_to_board(message)
  message.match(/[\s]*\@deepteal[\s]*(\|\S{7}\|\S{7}\|\S{7}\|\S{7}\|\S{7}\|\S{7}\|)[\s]*\#dbc_c4[\s]*/)
  return $1
end

def send_to_session(opponent, board)
  $sessions_container.each do |session|
    if session.player == opponent
      session.receive(board)
      return true
    end
  end
  false
end

def not_already_playing?(opponent)
  $sessions_container.each do |session|
    return false if session.player == opponent
  end
  return true
end

# ----------------------------------------------------------------------------------------
# Post a challenge and open the TweetStream
# ----------------------------------------------------------------------------------------

post_challenge

def listen_for_game
  TweetStream::Client.new.on_delete{ |status_id, user_id|
    Tweet.delete(status_id)
    }.on_limit { |skip_count|
      puts "skipping"
      sleep 5
    }.track('#dbc_c4') do |status|
      msg = status.text
      opponent = status.user.screen_name
      if not_already_playing?(opponent) && acceptance?(msg)
        Twitter.update("\@{opponent} get ready to be crushed!")
        start_game(opponent)
        post_challenge
      elsif board?(msg)
        board = strip_to_board(msg)
        start_game(opponent) unless send_to_session(opponent, board)
      elsif not_already_playing?(opponent) && take_challenge?(msg)
        Twitter.update("\@{opponent} Game on! \#dbc_c4")
        start_game(opponent)
      end
    end
end
