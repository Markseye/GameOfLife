# Initializes game with size of board
# need to update to allow previous board to be passed in
class GameOfLife
  def initialize(grid_size = 8, number_of_turns = 100)
    @grid_size = grid_size
    @grid = prepare_game
    @number_of_turns = number_of_turns
    run_game
  end

  def run_game
    output_grid(@grid, 1)
    (2..@number_of_turns).each do |n|
      next_grid = @grid.next_turn
      output_grid(next_grid, n)
    end
    # GameOfLife.new(next_grid)
  end

  private

  def prepare_game
    Grid.new(@grid_size)
  end

  def output_grid(grid, turn)
    puts "\n\n-------TURN #{turn}--------\n\n"
    grid.cells.each { |row| puts row.map(&:state).join(' ') }
  end
end

# Responsible for managing state of entire grid
class Grid
  attr_reader :size, :grid

  def initialize(size)
    @grid = []
    @size = size
    @grid = create_grid_cells
  end

  def next_turn
    # need to handle previous cell state
    cells.flatten.each(&:process_state)
    self
  end

  def cells
    @grid
  end

  private

  def create_grid_cells
    grid = []
    @size.times do |row|
      column_of_cells = []
      @size.times do |column|
        column_of_cells << Cell.new(self, row, column)
      end

      grid << column_of_cells
    end
    grid
  end
end

# Handles state and actions for each cell
class Cell
  STATES = { DEAD: 0, ALIVE: 1 }.freeze

  attr_accessor :state
  attr_reader :row, :column
  # attr_accessor :surrounding_cell_count

  def initialize(grid, row, column)
    @grid = grid
    @state = generate_random_state
    @row = row
    @column = column
  end

  def surrounding_cell_count
    # handle corners (only 3 neighbors)
    # handle edges (5 neighbors)
    # handle all others (8 neighbors)
    # should be on grid or else cell would need to know about grid
    # can this be simplified?
    # create single methods where you pass in your row and column and it returns state the state of that cell
    if corner?(@grid.size)
      if row == 0
        #extract @grid[row] , @grid[row + 1]
        variant = column == 0 ? @grid.cells[row + 1][column + 1].state + @grid.cells[row][column + 1].state : @grid.cells[row + 1][column - 1].state + @grid.cells[row][column - 1].state
        @grid.cells[row + 1][column].state + variant
      else
        variant = column == 0 ? @grid.cells[row - 1][column + 1].state + @grid.cells[row][column + 1].state  : @grid.cells[row - 1][column - 1].state  + @grid.cells[row][column - 1].state
        @grid.cells[row - 1][column]
      end
    elsif edge?(@grid.size)
      if column == 0 
        @grid.cells[row + 1][column + 1].state + @grid.cells[row - 1][column + 1].state + @grid.cells[row][column + 1].state
      elsif column == @grid.size - 1
        @grid.cells[row + 1][column - 1].state + @grid.cells[row - 1][column - 1].state + @grid.cells[row][column - 1].state
      elsif row == 0
        @grid.cells[row + 1][column - 1].state + @grid.cells[row + 1][column + 1].state + @grid.cells[row + 1][column].state
      else
        @grid.cells[row - 1][column - 1].state + @grid.cells[row - 1][column + 1].state + @grid.cells[row - 1][column].state
      end
    else
      above_below_sum + left_right_sum + top_corners_sum + bottom_corners_sum
    end
  end

  def process_state
    # only time dead state matter - dead to alive case
    if surrounding_cell_count == 3 && state.zero?
      flip_state!
    elsif state == 1
      flip_state! unless [2, 3].include?(surrounding_cell_count)
    end
    self
  end

  def action
    change_state = state == STATES::ALIVE ? kill? : live?
    change_state ? flip_state! : stagnant
  end

  def generate_random_state
    STATES[STATES.keys.sample]
  end

  def corner?(grid_size)
    (row == 0|| row == grid_size - 1) &&
      (column == 0 || column == grid_size - 1)
  end

  def edge?(grid_size)
    row == 0 ||
      row == grid_size - 1 ||
      column == 0 ||
      column == grid_size - 1
  end

  private

  def flip_state!
    !state
  end

  def kill?
    count = surrounding_cell_count
    return true if count > 3
    return true if count < 2

    false
  end

  def live?
    return true if surround_cell_count == 3

    false
  end

  def above_below_sum
    @grid.cells[row - 1][column].state + @grid.cells[row + 1][column].state
  end

  def left_right_sum
    @grid.cells[column + 1][row].state + @grid.cells[column - 1][row].state
  end

  def top_corners_sum
    @grid.cells[row - 1][column - 1].state + @grid.cells[row - 1][column + 1].state
  end

  def bottom_corners_sum
    @grid.cells[row + 1][column - 1].state + @grid.cells[row + 1][column + 1].state
  end
end

GameOfLife.new
