# Questions:
# should cell know about grid? - if not how to handle neighbors?
# add to ruby app or keep as standalone?
# testing through Test::Unit assertions?

# Initializes game with size of board
class GameOfLife
  attr

  def initialize(grid_size = 28)
    @grid_size = grid_size
    @grid = prepare_game
  end

  def surrounding_cell_count
    # handle corners (only 3 neighbors)
    # handle edges (5 neighbors)
    # handle all others (8 neighbors)
    if @cell.is_corner?
    else @cell.is_edge?
    end
  end

  def run_game
    @grid.next_turn
  end

  private

  def prepare_game
    Grid.new(@grid_size)
  end
end

# Responsible for managing state of entire grid
class Grid
  attr_reader :size, :grid

  def initialize(size)
    @size = size
    @grid = prepare_grid
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

  def surrounding_cell_count
    # will need to know size of row in order
    # to find surrounding cell state
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

Game.new
