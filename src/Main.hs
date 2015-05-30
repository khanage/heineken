module Main where

import System.Environment (getArgs)
import Development.Heineken

main :: IO ()
main = do
  args <- getArgs

  case args of
   (command:otherargs) -> openKeg
                          (Command command)
                          (CommandArgs otherargs)
                          
   _ -> putStrLn "usage: hein <cmd> <args*>"
