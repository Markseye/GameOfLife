# Questions:
# should cell know about grid? - if not how to handle neighbors?
# add to ruby app or keep as standalone?
# testing through Test::Unit assertions?

# Initializes game with size of board
class GameOfLife
  def initialize(grid_size = 28)
    @grid_size = grid_size
    @grid = prepare_game
    run_game
  end

  def run_game
    # will change as @grid change_state
    # previous_grid << @grid
    next_grid = @grid.next_turn
    puts output_grid(next_grid)
    GameOfLife.new(next_grid)
  end

  private

  def prepare_game
    Grid.new(@grid_size)
  end

  def output_grid(grid)
    grid.each { |row| puts row.join(' ') }
  end
end

# Responsible for managing state of entire grid
class Grid
  attr_reader :size, :grid

  def initialize(size)
    @size = size
    @grid = prepare_grid
  end

  def next_turn
    # need to handle previous cell state
    @grid.flatten.map(&:process_state)
  end

  def process_state
    # only time dead state matter - dead to alive case
    if surrounding_cell_count == 3 && @cell.state.zero?
      @cell.flip_state
    elsif @cell.state == 1
      @cell.flip_state unless [2, 3].include?(surrounding_cell_count)
    end
  end

  def surrounding_cell_count
    row = @cell.row
    column = @cell.column
    # handle corners (only 3 neighbors)
    # handle edges (5 neighbors)
    # handle all others (8 neighbors)
    # should be on grid or else cell would need to know about grid
    # if i flatten this can i just work with grid size rather than grid[row][cell]

    # can this be simplified?
    if @cell.is_corner?
      if row == 1
        #extract @grid[row] , @grid[row + 1]
        variant = column == 1 ? @grid[row + 1][column + 1] + @grid[row][column + 1] : @grid[row + 1][column - 1] + @grid[row][column - 1]
        @grid[row + 1][column] + variant
      else
        variant = column == 1 ? @grid[row - 1][column + 1] + @grid[row][column + 1] : @grid[row - 1][column - 1] + @grid[row][column - 1]
        @grid[row - 1][column]
      end
    elsif @cell.is_edge?
      variant =
        row == 1 ? bottom_corners_sum + @grid[row + 1][column] : top_corners_sum + @grid[row - 1][column]
      variant + left_right_sum
    else
      above_below_sum + left_right_sum + top_corners_sum + bottom_corners_sum
    end
  end

  private

  def prepare_grid
    create_grid_cells
  end

  def create_grid_cells
    @size.times do |row|
      row_of_cells = []
      @size.times do |column|
        row_of_cells << Cell.new(row, column)
      end

      @grid << row_of_cells
    end
  end

  def above_below_sum
    @grid[row - 1][column] + @grid[row + 1][column]
  end

  def left_right_sum
    @grid[column + 1][row] + @grid[column - 1][row]
  end

  def top_corners_sum
    @grid[row - 1][column - 1] + @grid[row - 1][column + 1]
  end

  def bottom_corners_sum
    @grid[row + 1][column - 1] + @grid[row + 1][column + 1]
  end
end

# Handles state and actions for each cell
class Cell
  STATES = { DEAD: 0, ALIVE: 1 }.freeze

  attr_accessor :state
  attr_accessor :surrounding_cell_count

  def initialize(row, column)
    @state = generate_random_state
    @row = row
    @column = column
  end

  def action
    change_state = state == STATES::ALIVE ? kill? : live?
    change_state ? flip_state! : stagnant
  end

  def generate_random_state
    STATES[STATES.keys.sample]
  end

  def corner?(grid_size)
    (row == 1 || row == grid_size) &&
      (column == 1 || column == grid_size)
  end

  def edge?(grid_size)
    row == 1 ||
      row == grid_size ||
      column == 1 ||
      column == grid_size
  end

  private

  def flip_state!
    state = !state
    save
    # exception if save fails
    state
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
end

GameOfLife.new
