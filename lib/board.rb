require_relative 'column'

class Board

  attr_reader :cells, :num_cols, :num_rows, :current_player

  def initialize(num_cols = 7, num_rows = 6)
    @cells = create_columns(num_cols)
    @num_rows = num_rows
    @num_cols = num_cols
    @current_column = 0
  end

  def place(column_index, player)
    @current_player = player
    cells[column_index].place(player, num_rows)
  end

  def create_columns(num_cols)
    (0..num_cols-1).reduce([]) { |cells| cells << Column.new }
  end

  def populate
    cells.each_with_index { |cell, index| 6.times { cell << index} }
  end

  def state
    if column_win? || row_win? || diagonal_win?
      return :win
    elsif tie?
      return :tie
    end
    nil
  end

  def tie?
    cells.inject(0) { |total_cells, column| total_cells += column.length } == num_rows * cells.length
  end

  def column_win?
    num_cols.times do |column_number|
      column_pieces = cells[column_number].join
      return true if connect_four?(column_pieces)
    end
    false
  end

  def row_win?
    @num_rows.times do |row_number|
      row_pieces = nil_to_hash_sign(@cells.map { |column| column[row_number] }).join
      return true if connect_four?(row_pieces)
    end
    false
  end

  def diagonal_win?
    num_cols.times do |current_column|
      @current_column = current_column
      first_pieces, second_pieces = diagonals.map { |diagonal| nil_to_hash_sign(diagonal).join }
      p first_pieces
      p second_pieces
      return true if connect_four?(first_pieces) || connect_four?(second_pieces)
    end
    false
  end

  def connect_four?(pieces)
    !(/1111|0000/.match(pieces)).nil?
  end

  def nil_to_hash_sign(array)
    array.map { |element| element.nil? ? "#" : element }
  end

  def diagonals
    puts cells[0]
    d0 = left_top + right_bottom
    d1 = left_bottom + right_top
    [d0, d1]
  end

  def right_bottom
    right_array, column_index, row_index = diagonal_elements

    until column_index == num_cols - 1 || row_index == 0
      column_index += 1
      row_index -= 1
      right_array << cells[column_index][row_index]
    end
    right_array
  end

  def left_top
    left_array, column_index, row_index = diagonal_elements

    until column_index == 0 || row_index == num_rows - 1
      puts "----"
      puts column_index
      puts "-----"
      column_index -= 1
      row_index += 1
      left_array << cells[column_index][row_index]
    end
    left_array.reverse
  end

    def right_top
    right_array, column_index, row_index = diagonal_elements

    until column_index == num_cols - 1 || row_index == num_rows - 1
      column_index += 1
      row_index += 1
      right_array << cells[column_index][row_index]
    end
    right_array
  end

  def left_bottom
    left_array, column_index, row_index = diagonal_elements

    until column_index == 0 || row_index == 0
      column_index -= 1
      row_index -= 1
      left_array << cells[column_index][row_index]
    end
    left_array.reverse
  end

  def show
    index = num_rows - 1
    puts ""
    num_rows.times do
      cells.each { |column| column[index] != nil ? (print "| #{column[index]} ") : (print "|   ") }
      index -= 1
      print "|\n"
    end
    puts "============================="
    puts "| 1 | 2 | 3 | 4 | 5 | 6 | 7 |"
  end

  private

  def diagonal_elements
    [[], @current_column, 2]
  end

end
