module Development.Heineken where

import           Control.Monad
import           Data.Char
import           Data.List                   (intercalate)
import           Debug.Trace                 (traceIO)

-- This is just a work around for now
import qualified Development.Heineken.New    as New
import           Development.Heineken.Plugin

newtype Command = Command { unCommand :: String }
newtype CommandArgs = CommandArgs { unCommandArgs :: [String] }

openKeg :: Command -> CommandArgs -> IO ()
openKeg c a = do

  let command  = unCommand c
      args     = unCommandArgs a

  let plugin = case toLower `fmap` command of
        "new" -> New.plugin

  putStrLn $ "Calling " ++ command ++ " with [" ++ intercalate " " args ++ "]."

  run plugin args
