{-# LANGUAGE OverloadedStrings #-}

module Site.Projects.Context where

import Data.Monoid ((<>), mempty)

import Hakyll

import W7W.Pictures.Context

import Site.Context
import Site.Paths

mkProjectCtx caches = do
      c <- mkSiteCtx caches
      return $ c
               <> (fieldPictures caches pPattern)
               <> (fieldHasPictures pPattern)
               <> (fieldFunctionPictureUrl pPattern)
  where
    pPattern = picturesPatternNg (Just "projects") "*"
