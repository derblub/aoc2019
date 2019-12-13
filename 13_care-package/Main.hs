
-- https://adventofcode.com/2019/day/12

--    ghc -dynamic Main.hs

module Main where
import qualified Data.Text.IO as T
import qualified CPython as Py

main :: IO ()
main = do
	Py.initialize
	Py.getVersion >>= T.putStrLn
