--Matthew Kunkel, Darryn Dunn, Reuben Havlan
module Main where

-- Defining a sample for a cave
cave1 :: [[Char]]
cave1 = [['O', 'O', 'O', 'O', 'P', 'O'],
          ['O', 'O', 'P', 'W', 'O', 'O'],
          ['O', 'O', 'O', 'P', 'O', 'P'],
          ['O', 'O', 'O', 'O', 'O', 'O']]

-- Function to test if a row/column is in bounds
inBounds :: Int -> [a] -> Bool
inBounds i section = i >= 0 && i < length section

-- Function to test if a point in the cave is out of bounds
outOfBounds :: Int -> Int -> [[a]] -> Bool
outOfBounds row col list = not (inBounds row list && inBounds col (list !! row))


replaceByIndex :: [a] -> Int -> a -> [a]
replaceByIndex [] _ _ = []
replaceByIndex list i current
-- If the index is out of bounds
    | not (inBounds i list) = list
    | i == 0 = current : tail list
-- Replace the index with desired character
    | otherwise = head list : replaceByIndex (tail list) (i - 1) current


replaceByIndices :: [[a]] -> Int -> Int -> a -> [[a]]
replaceByIndices list row col current
-- If the point is out of bounds
    | outOfBounds row col list = list
-- Find the desired point in the cave and set it to the desired character
    | otherwise = take row list ++ [replaceByRow (list !! row) col current] ++ drop (row + 1) list

-- Find the row and replace the index in the given row
replaceByRow :: [a] -> Int -> a -> [a]
replaceByRow [] _ _ = []
replaceByRow row i current
    | not (inBounds i row) = row
    | otherwise = take i row ++ [current] ++ drop (i + 1) row

-- Return a character at a certain point
findByIndices :: [[a]] -> Int -> Int -> a
findByIndices list row col = list !! row !! col


findWumpus :: [[Char]] -> String
findWumpus cave = 
	navigate "" cave 3 0 (replaceByIndices cave 3 0 'P')


navigate :: [Char] -> [[Char]] -> Int -> Int -> [[Char]] -> [Char]
navigate path cave row col after_move =
-- Wumpus has been found
	if findByIndices cave row col == 'W' then path
-- Wumpus is to the right
	else if col < 5 && findByIndices after_move row (col + 1) /= 'P' then navigate (path ++ ['r']) cave row (col + 1) (replaceByIndices after_move row col 'P')
-- Wumpus is above the player
	else if row >= 1 && findByIndices after_move (row - 1) col /= 'P' then navigate (path ++ ['u']) cave (row - 1) col (replaceByIndices after_move row col 'P')
-- Wumpus is to the left
	else if col >= 1 && findByIndices after_move row (col - 1) /= 'P' then navigate (path ++ ['l']) cave row (col - 1) (replaceByIndices after_move row col 'P')
-- Wumpus is below the player
	else if row < 3 && findByIndices after_move (row + 1) col /= 'P' then navigate (path ++ ['d']) cave (row + 1) col (replaceByIndices after_move row col 'P')
-- There is not a move that will reach Wumpus or is invalid
	else navigate "" (replaceByIndices cave row col 'P') 3 0 (replaceByIndices cave row col 'P')


main :: IO ()
main = do
    putStrLn ("Finding Wumpus: " ++ show (findWumpus cave1))

