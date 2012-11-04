require_relative '../lib/board'
require 'simplecov'
SimpleCov.start

describe Board do
  let(:player) { 1 }
  let(:num_columns) { 7 }
  let(:num_rows) { 6 }
  let(:board) { Board.new(num_columns, num_rows) }
  let(:WIN) { GameState.new(2, "WIN") }
  let(:TIE) { GameState.new(1, "TIE") }
  let(:LOSE) { GameState.new(0, "LOSE") }

  it "creates a board with specified number of columns and rows" do
    board.cells.length.should eq num_columns
  end

  it "places a piece in the specified column" do
    board.place(1, player).should be_true
  end

  it "does not place a piece in a column is full" do
    num_rows.times { board.place(2, player) }
    board.place(2, player).should be_false
  end

  context "column wins" do
    it "is a column win" do
      4.times { board.place(2, player) }
      board.column_win?.should be_true
    end

    it "is not a column win" do
      3.times { board.place(2, player) }
      board.column_win?.should be_false
    end
  end

  context "row wins" do
    it "is a row win" do
      4.times do |index|
        board.place(index, player)
      end
      board.row_win?.should be_true
    end

    it "is not row win" do
      3.times do |index|
        board.place(index, player)
      end
      board.row_win?.should be_false
    end
  end

  context "constructing diagonals" do
    it "has a diagonal, [0, nil, 2, 3, 4]" do
      5.times { board.place(4, 4) }
      5.times { board.place(3, 3) }
      5.times { board.place(2, 2) }
      5.times { board.place(0, 0) }
      board.diagonals[0].should eq [0, nil, 2, 3 ,4]
    end

    it "has a diagonal, [4, 5, 6]" do
      6.times { board.place(6, 6) }
      6.times { board.place(5, 5) }
      6.times { board.place(4, 4) }
      board.diagonals[0].should eq [4, 5, 6]
    end

    it "has a diagonal, [nil, 2, 3, 4, nil, nil]" do
      5.times { board.place(4, 4) }
      5.times { board.place(3, 3) }
      5.times { board.place(0, 0) }
      5.times { board.place(2, 2) }
      board.diagonals[0].should eq [nil, 2, 3 ,4, nil, nil]
    end

    it "has a diagonal, [4, 5, 6]" do
      6.times { board.place(0, 0) }
      6.times { board.place(1, 1) }
      6.times { board.place(2, 2) }
      board.diagonals[1].should eq [0, 1, 2]
    end

    it "has a diagonal, [4, 5, 6]" do
      6.times { board.place(0, 0) }
      6.times { board.place(1, 1) }
      4.times { board.place(3, 3) }
      4.times { board.place(5, 5) }
      board.diagonals[1].should eq [nil, 3, nil, 5, nil]
    end
  end

  context "diagonal wins" do

    it "is a diagonal win" do
      4.times { board.place(6, player) }
      3.times { board.place(5, player) }
      2.times { board.place(4, player) }
      1.times { board.place(3, player) }
      board.diagonal_win?.should be_true
    end

    it "is a diagonal win" do
      5.times { board.place(1, player) }
      4.times { board.place(2, player) }
      3.times { board.place(3, player) }
      2.times { board.place(4, player) }
      board.diagonal_win?.should be_true
    end

    it "is not a diagonal win" do
      3.times { board.place(6, player) }
      2.times { board.place(5, player) }
      1.times { board.place(4, player) }
      board.diagonal_win?.should be_false
    end

  end

  it "is a tie" do
    num_columns.times do |index|
      num_rows.times { board.place(index, player) }
    end
    board.tie?.should be_true
  end

  it "is an ongoing game" do
    1.times { board.place(4, player) }
    board.state.should be_nil
  end

end
