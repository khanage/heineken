module Development.Heineken.Plugin where

data HeinekenPlugin = HeinekenPlugin { run :: [String] -> IO () }
