module Development.Heineken where

import           Control.Monad
import           Data.Char
import           Data.List                   (intercalate)
import           Debug.Trace                 (traceIO)
import           System.Plugins

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


  -- TODO: Work out how to make this work
  -- build <- makeAll "src/Development/Heineken/New.hs" ["-i src/"]

  -- case build of
  --  MakeFailure errors -> do
  --    putStrLn $ "============= Errors building ============="
  --    forM_ errors putStrLn
  --  MakeSuccess code obj -> do

  --    traceIO $ "Built with code " ++ show code
  --    traceIO $ "Built file " ++ show obj

  --    -- module' <- loadModule obj

  --    -- traceIO $ "Loaded module " ++ mname module'

  --    loaded <- load_ obj ["../.."] "plugin" :: IOo (LoadStatus HeinekenPlugin)

  --    traceIO "Loaded"

  --    case loaded of
  --     LoadFailure errors -> putStrLn $ "Got errors: " ++ show errors
  --     LoadSuccess _ a -> do
  --       let HeinekenPlugin plugin = a
  --       plugin command args
