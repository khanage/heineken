module Development.Heineken.New (plugin) where

import           Development.Heineken.Plugin (HeinekenPlugin (..))

import           Control.Applicative         ((<|>))
import           Control.Monad.Trans.Maybe   (MaybeT (..), runMaybeT)
import qualified Data.ByteString.Lazy        as L
import           Data.List                   (intercalate, stripPrefix)
import           Data.Maybe                  (catMaybes)
import           Network.HTTP.Conduit        (simpleHttp)
import           System.Directory
import           System.Exit
import           System.FilePath
import           System.IO
import           System.Process

newtype UserDetails = UserDetails { unUserDetails :: (String,String) } deriving (Show, Eq)

userDetails :: IO UserDetails
userDetails = do
  Just details <- runMaybeT (readFromGitconfig <|> askDetails)
  return details
  where
    readFromGitconfig = MaybeT $ do

      username <- readProcess "git" ["config", "--global", "--get", "user.name"] ""
      email    <- readProcess "git" ["config", "--global", "--get", "user.email"] ""

      if null username || null email
        then return Nothing
        else return . Just $ UserDetails (username, email)

    askDetails = MaybeT $ do
      putStrLn "Couldn't infer details!"

      putStrLn "Enter name"
      name <- getLine

      putStrLn "Enter email"
      email <- getLine

      let details = UserDetails (name, email)

      return (Just details)

dependenciesIn :: [String] -> [String] -> [String]
dependenciesIn defs args =
  let startingWithPlus = catMaybes $ map (stripPrefix "+") args
      mapped = map ("--dependency=" ++) $ defs ++ startingWithPlus
  in mapped

plugin :: HeinekenPlugin
plugin = HeinekenPlugin
       $ \args -> do
         let packageName = head args

         putStrLn $ "Creating new project named " ++ packageName

         alreadyExists <- doesDirectoryExist packageName
         if (not alreadyExists) then createDirectory packageName else return ()

         setCurrentDirectory packageName

         UserDetails (user, email) <- userDetails
         let license = "Apache-2.0"
             language = "Haskell2010"
             sourceDir = "src"
             mainFile = "Main.hs"
             mainFilePath = sourceDir </> mainFile
             defaultDependencies = ["base >=4.7 && <4.8"]
             dependencies = dependenciesIn defaultDependencies args

         putStrLn "Creating sandbox..."
         ExitSuccess <- rawSystem "cabal" ["sandbox", "init"]

         putStrLn "Initialising cabal..."
         ExitSuccess <- rawSystem "cabal" $
                        [ "init", "-n"
                        , "--is-executable"
                        , "--package-name=" ++ packageName
                        , "--author=" ++ user
                        , "--email=" ++ email
                        , "--license=" ++ license
                        , "--language=" ++ language
                        , "--source-dir=" ++ sourceDir
                        , "--main-is=" ++ mainFile]
                        ++ dependencies

         putStrLn "Creating initial main file"
         createDirectoryIfMissing True sourceDir

         writeFile mainFilePath $ intercalate "\n"
           [ "module Main where"
           , ""
           , "main :: IO ()"
           , "main = putStrLn \"" ++ packageName ++ "!\""
           ]

         putStrLn "Running build"
         ExitSuccess <- rawSystem "cabal" ["install"]

         putStrLn "Initialising a git repo"
         rawSystem "git" ["init"]

         putStrLn "Add git ignore"
         simpleHttp "https://raw.githubusercontent.com/github/gitignore/master/Haskell.gitignore" >>= L.writeFile ".gitignore"

         putStrLn "Initial commit"
         rawSystem "git" ["add", "."]
         rawSystem "git" ["commit", "-m", "\"Initial commit\""]

         putStrLn "Running app"
         rawSystem "cabal" ["run"]

         return ()
