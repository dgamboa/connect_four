require 'sqlite3'
require 'twitter'
require 'tweetstream'
require 'yaml'
require_relative 'session'

class TwitterConnectFour
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

  def post_challenge
    post_id = Time.now.strftime("%F %T.%L")
    Twitter.update("Who wants to get demolished? #dbc_c4 #{post_id}")
    listen_for_game
  end

  def challenge?(message)
    return !(message =~ /[\s]*\@deepteal[\s]*[G|g]ame[\s]*on[!]?[\s]*\#dbc_c4[\s]*/).nil?
  end

  def board?(message)
    return !(message =~ /[\s]*\@deepteal[\s]*|[.+]|[.+]|[.+]|[.+]|[.+]|[.+]|[\s]*\#dbc_c4[\s]*/).nil?
  end

  def start_game(player)
    Session.new(player)
  end

  def send_to_session(player, board)

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
          send_to_session(player, board)
          #needs to check if session exists
          #  no? initiate a session
          # yes? send board to right session
        end
    end
  end
end

TwitterGame.new