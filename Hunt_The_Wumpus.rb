# PROGAMMERS: Darryn Dunn, Matthew Kunkel, Ruben Havlan
# DATE: 2021-09-30
# ASSIGNMENT: 6
# Class representing a generic location in the maze
class Location
  # Method to represent the location when printed
  def print
    "O"  # Default representation for an empty location
  end

  # Method called when the player visits the location
  def visit
    puts ""  # Placeholder for any visit-related actions
  end
end

# Class representing a pit, inheriting from Location
class Pit < Location
  # Override print method to show 'p' for pit
  def print
    "O"  # Hidden as "O" during gameplay
  end

  # Override visit method to handle pit interaction
  def visit
    puts "Ahhhh! You fell into a pit..."  # Message when the player falls into a pit
  end
end

# Class representing the Wumpus, inheriting from Location
class Wumpus < Location
  # Override print method to show 'w' for Wumpus
  def print
    "O"  # Hidden as "O" during gameplay
  end

  # Override visit method to handle Wumpus interaction
  def visit
    puts "Uh oh! You got eaten by the wumpus..."  # Message when the player encounters the Wumpus
  end
end

# Class to manage the game state and mechanics
class Game
  attr_accessor :maze, :player_x, :player_y, :game_state

  # Constants for the maze dimensions and number of pits
  BOARD_SIZE_X = 6
  BOARD_SIZE_Y = 4
  NUM_PITS = 4

  def initialize
    # Initialize the maze as a 2D array filled with Location objects
    @maze = Array.new(BOARD_SIZE_Y) { Array.new(BOARD_SIZE_X) { Location.new } }
    @player_x = 0  # Player starts at the leftmost position
    @player_y = BOARD_SIZE_Y - 1  # Player starts at the bottom row
    @game_state = 0  # Game state: 0 means the game is ongoing

    add_pits  # Add pits to the maze
    add_wumpus  # Add a Wumpus to the maze
  end

  # Method to randomly place pits in the maze
  def add_pits
    pit_positions = []  # Array to keep track of pit positions

    while pit_positions.size < NUM_PITS
      x, y = rand(BOARD_SIZE_X), rand(BOARD_SIZE_Y)  # Generate random coordinates
      position = [x, y]  # Create a position array

      # Ensure valid space, uniqueness, and that it's not the starting position or adjacent to it
      if valid_space?(x, y) && !pit_positions.include?(position) && !adjacent_to_player?(x, y)
        @maze[y][x] = Pit.new  # Place a pit in the maze
        pit_positions << position  # Add position to the list of pit positions
      end
    end
  end

  # Method to randomly place the Wumpus in the maze
  def add_wumpus
    loop do
      x, y = rand(BOARD_SIZE_X), rand(BOARD_SIZE_Y)  # Generate random coordinates for Wumpus
      # Ensure the Wumpus is not placed in the starting position or adjacent to it
      if valid_space?(x, y) && !adjacent_to_player?(x, y)
        @maze[y][x] = Wumpus.new  # Place the Wumpus in the maze
        break  # Exit the loop once the Wumpus is placed
      end
    end
  end

  # Method to validate if a space is suitable for placing a pit or Wumpus
  def valid_space?(x, y)
    !(x == 0 && y == BOARD_SIZE_Y - 1) && @maze[y][x].is_a?(Location)  # Ensure not on the player starting position
  end

  # Method to check if a given position is adjacent to the player's position
  def adjacent_to_player?(x, y)
    # List of positions adjacent to the player's starting position
    adjacent_positions = [
      [@player_x, @player_y - 1],  # Above
      [@player_x, @player_y + 1],  # Below
      [@player_x - 1, @player_y],  # Left
      [@player_x + 1, @player_y]   # Right
    ]
    adjacent_positions.include?([x, y])  # Check if (x, y) is one of the adjacent positions
  end

  # Method to print the current state of the maze
  def print_board
    @maze.each_with_index do |row, y|
      row.each_with_index do |location, x|
        if x == @player_x && y == @player_y
          print "X "  # Show player location
        else
          print "#{location.print} "  # Hide everything else
        end
      end
      puts ""  # New line after each row
    end
  end

  # Method to reveal the entire board upon game over
  def reveal_board
    @maze.each_with_index do |row, y|
      row.each_with_index do |location, x|
        if location.is_a?(Pit)
          print "p "  # Show pits
        elsif location.is_a?(Wumpus)
          print "w "  # Show Wumpus
        else
          print "O "  # Show empty locations
        end
      end
      puts ""  # New line after each row
    end
  end

  # Main game loop
  def play
    until @game_state != 0  # Continue until the game state is no longer 0
      print_board  # Print the current board state
      check_breeze_and_stench  # Check for nearby hazards
      print_options  # Display movement and shooting options
      input = gets.chomp  # Get user input
      if input == 's'
        print_shoot_options  # Display shooting options
        shoot(gets.chomp)  # Execute shooting action
      else
        move_player(input)  # Move the player based on input
      end
    end
    puts "Game Over!"  # Inform the player the game has ended
    reveal_board  # Reveal the board upon game over
  end

  # Check for nearby pits and Wumpus, displaying appropriate messages
  def check_breeze_and_stench
    if check_breeze
      puts "You feel a breeze."  # Indicate nearby pits
    end
    if check_stench
      puts "You smell a stench."  # Indicate nearby Wumpus
    end
  end

  # Check if there's a breeze (indicating nearby pits)
  def check_breeze
    nearby_pit?
  end

  # Check if there's a stench (indicating nearby Wumpus)
  def check_stench
    nearby_wumpus?
  end

  # Check if any adjacent location contains a pit
  def nearby_pit?
    adjacent_to?(Pit)
  end

  # Check if any adjacent location contains the Wumpus
  def nearby_wumpus?
    adjacent_to?(Wumpus)
  end

  # General method to check if a specific entity is adjacent
  def adjacent_to?(entity)
    # Check all four adjacent locations
    [[@player_y - 1, @player_x], [@player_y + 1, @player_x], [@player_y, @player_x - 1], [@player_y, @player_x + 1]].any? do |y, x|
      y.between?(0, BOARD_SIZE_Y - 1) && x.between?(0, BOARD_SIZE_X - 1) && @maze[y][x].is_a?(entity)
    end
  end

  # Method to print movement options for the player
  def print_options
    puts "\n u: move up\n d: move down\n l: move left\n r: move right\n s: shoot arrow\n\nEnter option: "
  end

  # Method to print shooting options for the player
  def print_shoot_options
    puts "\n u: shoot arrow up\n d: shoot arrow down\n l: shoot arrow left\n r: shoot arrow right\n\nEnter option: "
  end

  # Method to move the player based on input direction
  def move_player(dir)
    case dir
    when 'u'
      @player_y -= 1 if @player_y > 0  # Move up
    when 'd'
      @player_y += 1 if @player_y < BOARD_SIZE_Y - 1  # Move down
    when 'l'
      @player_x -= 1 if @player_x > 0  # Move left
    when 'r'
      @player_x += 1 if @player_x < BOARD_SIZE_X - 1  # Move right
    else
      puts "Invalid input!"  # Handle invalid input
    end
    check_position  # Check the new position after movement
  end

  # Method to check the player's current position for interactions
  def check_position
    @maze[@player_y][@player_x].visit  # Call visit method on the current location
    check_collide  # Check for collisions with pits or Wumpus
  end

  # Method to check for collisions with pits or the Wumpus
  def check_collide
    if @maze[@player_y][@player_x].is_a?(Pit)
      @game_state = -1  # Set game state to lost if in a pit
    elsif @maze[@player_y][@player_x].is_a?(Wumpus)
      @game_state = -1  # Set game state to lost if eaten by Wumpus
    end
  end

  # Method to handle the shooting action based on input direction
  def shoot(dir)
    case dir
    when 'u'
      check_shoot(@player_x, @player_y - 1)  # Shoot up
    when 'd'
      check_shoot(@player_x, @player_y + 1)  # Shoot down
    when 'l'
      check_shoot(@player_x - 1, @player_y)  # Shoot left
    when 'r'
      check_shoot(@player_x + 1, @player_y)  # Shoot right
    else
      puts "Invalid input!"  # Handle invalid input
    end
  end

  # Method to check if a shot hits the Wumpus
  def check_shoot(x, y)
    if y.between?(0, BOARD_SIZE_Y - 1) && x.between?(0, BOARD_SIZE_X - 1)  # Ensure within bounds
      if @maze[y][x].is_a?(Wumpus)
        puts "You killed the Wumpus!"  # Message for successfully killing the Wumpus
        @game_state = -1  # End the game
      else
        puts "You missed!"  # Message for missing the shot
      end
    else
      puts "You shot out of bounds!"  # Message for shooting out of bounds
    end
  end
end

# Starting point of the game
game = Game.new
game.play
