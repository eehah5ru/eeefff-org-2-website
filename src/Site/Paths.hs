{-# LANGUAGE OverloadedStrings #-}

module Site.Paths where

import System.FilePath.Posix ((</>), takeBaseName)

import Hakyll

import W7W.Utils

picturesPattern :: String -> Item a -> Pattern
picturesPattern p i =
  fromGlob $ "images" </> (itemCanonicalName i) </> p
