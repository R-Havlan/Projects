// Reuben Havlan, Darryn Dunn, Matthew Kunkel


// std and print
const std = @import("std");
const print = std.debug.print;


// board dimensions in X (horizontal) and Y (vertical) axes, as well as a custom number of pits
// accessing board spaces is board[Y][X]
const BOARD_SIZE_X = 6;
const BOARD_SIZE_Y = 4;
const NUM_PITS = 4;


// board is used to hold the locations of pits and wumpus
// displayBoard is used to print the player's location
// they are both initialized to all 'O' by these lines
var board:        [BOARD_SIZE_Y][BOARD_SIZE_X]u8 = .{.{'O'} ** BOARD_SIZE_X} ** BOARD_SIZE_Y;
var displayBoard: [BOARD_SIZE_Y][BOARD_SIZE_X]u8 = .{.{'O'} ** BOARD_SIZE_X} ** BOARD_SIZE_Y;


// player X and Y coordinates, used for collision
var playerX: usize = 0;
var playerY: usize = BOARD_SIZE_Y-1;


// state of the game. 0 = running, !0 = finished
var gameState: i2 = 0;


// function to run through the initial board modifier functions
// the player is added to 'board' so that pits and wumpus don't spawn directly on the player. the X is removed after
pub fn boardInit() void {
	board[playerY][playerX] = 'X';
	displayBoard[playerY][playerX] = 'X';
	addPits();
	addWumpus();
	board[playerY][playerX] = 'O';
}


// creates a random coordinate pair until that space is not taken, then puts a pit there
// does this NUM_PITS times
pub fn addPits() void {
	const rand = std.crypto.random;
	
	var newX: usize = 0;
	var newY: usize = 0;
	var i: i8 = 0;
	
	while(i < NUM_PITS) {
		newX = rand.intRangeAtMost(usize, 0, BOARD_SIZE_X-1);
		newY = rand.intRangeAtMost(usize, 0, BOARD_SIZE_Y-1);
		if(validSpace(newX, newY)) {
			board[newY][newX] = 'p';
			i = i + 1;
		}
	}
}


// works the same as addPits but changes the space to 'w' instead
// only does this once
pub fn addWumpus() void {
	const rand = std.crypto.random;
	
	var newX: usize = rand.intRangeAtMost(usize, 0, BOARD_SIZE_X-1);
	var newY: usize = rand.intRangeAtMost(usize, 0, BOARD_SIZE_Y-1);
	
	while(!validSpace(newX, newY)) {
		newX = rand.intRangeAtMost(usize, 0, BOARD_SIZE_X-1);
		newY = rand.intRangeAtMost(usize, 0, BOARD_SIZE_Y-1);
	}
	
	board[newY][newX] = 'w';
}


// simple function to see if coordinate pair is already taken on the board
pub fn validSpace(x: usize, y: usize) bool {
	if(board[y][x] != 'O') return false;
	return true;
}


// checks each side of the player for 1: the space exists and 2: it is 'p'
// if so, return true
pub fn checkBreeze() bool {
	if(playerX > 0 and board[playerY][playerX-1] == 'p') return true;
	if(playerX+1 < BOARD_SIZE_X and board[playerY][playerX+1] == 'p') return true;
	if(playerY > 0 and board[playerY-1][playerX] == 'p') return true;
	if(playerY+1 < BOARD_SIZE_Y and board[playerY+1][playerX] == 'p') return true;
	return false;
}


// same as checkBreeze but for 'w'
pub fn checkStench() bool {
	if(playerX > 0 and board[playerY][playerX-1] == 'w') return true;
	if(playerX+1 < BOARD_SIZE_X and board[playerY][playerX+1] == 'w') return true;
	if(playerY > 0 and board[playerY-1][playerX] == 'w') return true;
	if(playerY+1 < BOARD_SIZE_Y and board[playerY+1][playerX] == 'w') return true;
	return false;
}


// takes an integer input and attempts to move the player
// 0 = up, 1 = down, 2 = left, 3 = right
// if the space exists, change player coordinate and update displayBoard
// then, check if the player is colliding with a special space
pub fn movePlayer(dir: i4) void {
	switch(dir) {
		0 => {
			if(playerY > 0) {
				displayBoard[playerY][playerX] = 'O';
				playerY -= 1;
				displayBoard[playerY][playerX] = 'X';
			} 
		},
		1 => {
			if(playerY < BOARD_SIZE_Y-1) {
				displayBoard[playerY][playerX] = 'O';
				playerY += 1;
				displayBoard[playerY][playerX] = 'X';
			}
		},
		2 => {
			if(playerX > 0) {
				displayBoard[playerY][playerX] = 'O';
				playerX -= 1;
				displayBoard[playerY][playerX] = 'X';
			}
		},
		3 => {
			if(playerX < BOARD_SIZE_X-1) {
				displayBoard[playerY][playerX] = 'O';
				playerX += 1;
				displayBoard[playerY][playerX] = 'X';
			}
		},
		else => print("Something went wrong", .{})
	}
	checkCollide();
}


// checks if the player coordinates intersects with a pit or wumpus
// if so, print the appropriate message and end the game
pub fn checkCollide() void {
	switch(board[playerY][playerX]) {
		'p' => {
			print("\nYou fell into a pit\n", .{});
			gameState = 1;
		},
		'w' => {
			print("\nYou got eaten by the wumpus\n", .{});
			gameState = 1;
		},
		else => return
	}
}


// similar to movePlayer, takes an integer for direction
// 0 = up, 1 = down, 2 = left, 3 = right
// if the space exists and is 'w', print victory message
// if not, print failure message
// the game always ends after shooting an arrow, hence the gameState change
pub fn shoot(dir: i4) void {
	switch(dir) {
		0 => {
			if(playerY > 0 and board[playerY-1][playerX] == 'w') {
				print("You have successfully hunted the wumpus\n", .{});
			} else {
				print("You missed the wumpus\n", .{});
			}
		},
		1 => {
			if(playerY < BOARD_SIZE_Y-1 and board[playerY+1][playerX] == 'w')  {
				print("You have successfully hunted the wumpus\n", .{});
			} else {
				print("You missed the wumpus\n", .{});
			}
		},
		2 => {
			if(playerX > 0 and board[playerY][playerX-1] == 'w')  {
				print("You have successfully hunted the wumpus\n", .{});
			} else {
				print("You missed the wumpus\n", .{});
			}
		},
		3 => {
			if(playerX < BOARD_SIZE_X-1 and board[playerY][playerX+1] == 'w')  {
				print("You have successfully hunted the wumpus\n", .{});
			} else {
				print("You missed the wumpus\n", .{});
			}
		},
		else => print("Something went wrong", .{})
	}
	
	gameState = 1;
}


// prints each line of displayBoard, after a newline
pub fn printBoard() void {
	print("\n", .{});
	for (0..4) |i| {
		print("{s}\n", .{displayBoard[i]});
	}
}


// prints each line of board, after a newline
pub fn printHiddenBoard() void {
	print("\n", .{});
	for (0..4) |i| {
		print("{s}\n", .{board[i]});
	}
}


// takes a bool input to decide which menu to print
// true = main menu, false = arrow menu
pub fn printOptions(menu: bool) void {
	if(menu) {
		print("\n u: move up\n d: move down\n l: move left\n r: move right\n s: shoot arrow\n\nEnter option:  ", .{});
	} else {
		print("\n u: shoot arrow up\n d: shoot arrow down\n l: shoot arrow left\n r: shoot arrow right\n\nEnter option:  ", .{});
	}
}


// main function loops printing the board, printing the menus and collecting inputs until the game is over (gameState != 0)
// readUntilDelimiter automatically puts the entered string into input, the "_ = " is so that the return value can go somewhere and "try" is used to appease the compiler
// when the game is over, print the hidden board and wait for one more input before closing
pub fn main() !void {
	const reader = std.io.getStdIn().reader();
	var input: [16]u8 = undefined;
	
	boardInit();
	
	while(gameState == 0) {
		printBoard();
		if(checkBreeze()) {
			print("You feel a breeze\n", .{});
		}
		if(checkStench()) {
			print("You smell a stench\n", .{});
		}
		printOptions(true);
		
		_ = try reader.readUntilDelimiter(&input, '\n');
		switch(input[0]) {
			'u' => movePlayer(0),
			'd' => movePlayer(1),
			'l' => movePlayer(2),
			'r' => movePlayer(3),
			's' => {
				printOptions(false);
				_ = try reader.readUntilDelimiter(&input, '\n');
				switch(input[0]) {
					'u' => shoot(0),
					'd' => shoot(1),
					'l' => shoot(2),
					'r' => shoot(3),
					else => print("Invalid input\n", .{})
				}
			},
		else => print("Invalid input\n", .{})
		}
	}
	
	printHiddenBoard();
	print("Press enter to close\n", .{});
	_ = try reader.readUntilDelimiter(&input, '\n');
}