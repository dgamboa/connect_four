require 'sqlite3'
require 'twitter'
require 'tweetstream'
require 'yaml'

class Session
  attr_reader :player

  def initialize(opponent)
    @player = opponent
    # send to initialization of game that outputs a new board with move and calls send_board_back
  end

  def receive(board)
    # call method that runs the game on a string board and send_board_back
  end

  def send_board_back(board_to_send)
    post_id = Time.now.strftime("%F %T.%L")
    Twitter.update("\@#{player} #{board_to_send} #dbc_c4 #{post_id}")
  end
end


# A session object should have a player attr_reader that containes the opponent's username (for session_handler check and to know who to send to)
# It should also have a method #receive that takes in a board in string format
# It should also have an initialize method that takes in a player in the format 'username' not '@username'



# @current_challenger
# receive a board
# transpose a board
#   from twitter format
# make a move
#   to twitter format
# tweet move
# close session when game over
# save results to db

# session should know when someone wins and tweet back accordingly