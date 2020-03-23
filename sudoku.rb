require 'pry'

class Group < Array
  attr_reader :number

  def initialize(number)
    @number = number
    super()
  end

  def eval
    (1..9).select do |i|
      update_possibilities
      matching_cells = select { |cell| cell.possibilities.include?(i) }

      if matching_cells.size == 1
        cell = matching_cells.first

        # puts "[+] Number #{i} assigned to cell in #{cell.coords}"
        cell.assign(i)
        cell.groups.each(&:update_possibilities)

        true
      else
        false
      end
    end.any?
  end

  def update_possibilities
    each(&:eval)
  end
end

class Cell
  attr_accessor :value, :row, :column, :block, :possibilities, :sudoku

  def initialize(sudoku, row, column, block)
    @sudoku = sudoku
    @row = row
    @column = column
    @block = block
    @possibilities = (1..9).to_a
  end

  def groups
    [row, column, block]
  end

  def accept?(num)
    [row, column, block].none? { |g| g.any? { |cell| cell.value == num } }
  end

  def coords
    [row.number, column.number]
  end

  def inspect
    to_s
  end

  def to_s
    @value || ' '
  end

  def assign(n)
    raise 'Invalid' unless accept?(n)

    @value = n
  end

  def remove_possibilities(pos)
    @possibilities -= pos
  end

  def eval
    unless value.nil?
      @possibilities = []
      return
    end

    @possibilities -= (1..9).reject { |n| accept?(n) }

    if @possibilities.size == 1
      assign(possibilities.first)
      @possibilities = []
      # puts "[*] Number #{@value} assigned to cell in #{coords}"
      return true
    end

    false
  end
end

class Sudoku
  attr_reader :rows, :columns, :blocks, :cells
  def initialize
    @rows = Array.new(9) { |i| Group.new(i) }
    @columns = Array.new(9) { |i| Group.new(i) }
    @blocks = Array.new(9) { |i| Group.new(i) }
    @cells = []

    (0...9**2).each do |i|
      row_index = i / 9
      column_index = i % 9

      meta_row = row_index / 3
      meta_column = column_index / 3
      block_index = 3 * meta_row + meta_column

      cell = Cell.new(self, rows[row_index], columns[column_index], blocks[block_index])

      @rows[row_index] << cell
      @columns[column_index] << cell
      @blocks[block_index] << cell
      @cells << cell
    end
  end

  def load(array)
    return load(array.delete("\n").delete(',').split('')) if array.is_a?(String)

    array.each_with_index do |v, i|
      cells[i].value = v.to_i unless v.nil? || v == ' '
    end

    direct_cell_eval
  end

  def recursive_full_eval
    return unless full_eval

    recursive_full_eval
  end

  def full_eval
    direct_cell_eval | columns.any?(&:eval) | rows.any?(&:eval) | blocks.any?(&:eval)
  end

  def direct_cell_eval
    cells.map(&:eval).any?
  end
end

class Printer
  attr_reader :sudoku
  def initialize(sudoku)
    @sudoku = sudoku
  end

  def print
    sudoku.rows.map do |row|
      row.map(&:to_s).join(' ')
    end.each { |r| puts r }
    puts

    nil
  end
end

sudoku_1 = [
  6, nil, nil, 8, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, nil, 4, 6, nil,
  nil, 3, nil, nil, 5, nil, nil, nil, 8,
  nil, nil, nil, nil, 9, 4, nil, nil, 6,
  nil, 9, nil, nil, 3, nil, nil, nil, nil,
  nil, nil, nil, 7, nil, 8, 5, nil, 4,
  4, nil, nil, nil, nil, nil, nil, nil, nil,
  nil, nil, nil, nil, nil, 9, nil, nil, 3,
  8, nil, nil, nil, nil, 5, 6, 2, 9
]

sudoku_2 = [
  9, nil, nil, 2, nil, nil, 1, nil, nil,
  nil, 4, 6, 1, nil, nil, 3, 7, nil,
  nil, nil, nil, nil, 4, nil, nil, nil, nil,
  nil, 3, nil, 9, nil, nil, nil, nil, 7,
  nil, nil, nil, nil, 6, nil, nil, 4, nil,
  4, nil, nil, nil, 8, nil, 5, nil, 1,
  nil, 7, nil, nil, nil, 1, nil, nil, nil,
  nil, 8, 3, 6, nil, nil, nil, 2, nil,
  nil, nil, nil, 8, nil, nil, nil, nil, 5
]

sudoku_3 = "
9  2  1  ,
 461  37 ,
    4    ,
 3 9    7,
    6  4 ,
4   8 5 1,
 7   1   ,
 836   2 ,
   8   15,
"

sudoku_online = "
54  2 8 6,
 19  7  3,
   3  21 ,
9  4 5 2 ,
  1   6 4,
6 4 32 8 ,
 6    19 ,
4 2  9  5,
 9  7 4 2,
"

sudoku_online_difficult = "
 9       ,
    1382 ,
2 1   4  ,
 3 6  1 5,
  6 3 9  ,
5 4  1 3 ,
  8   2 1,
 2548    ,
       4 ,
"

def test(raw)
  s = Sudoku.new
  s.load(raw)
  s.recursive_full_eval
  Printer.new(s).print
end

test(sudoku_1)
test(sudoku_2)
test(sudoku_3)
test(sudoku_online)
test(sudoku_online_difficult)
