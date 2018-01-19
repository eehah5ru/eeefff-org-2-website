{-# LANGUAGE OverloadedStrings #-}

module Site.Projects.Context where

import Data.Monoid ((<>), mempty)

import Hakyll

import W7W.Pictures.Context

import Site.Context
import Site.Paths

projectCtx = siteCtx
             <> (fieldPictures pPattern)
             <> (fieldHasPictures pPattern)
             <> (fieldFunctionPictureUrl pPattern)
  where
    pPattern = picturesPattern "*"
