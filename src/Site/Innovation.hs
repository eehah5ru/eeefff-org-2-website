{-# LANGUAGE OverloadedStrings #-}

module Site.Innovation where

import Hakyll

import W7W.Compilers.Slim
import W7W.Rules.StaticPages

import Site.Templates
import Site.Context
import W7W.Utils

innovationRules = do
  match (("innovation/*.html") .||. ("innovation/**/*")) $ do
    route idRoute
    compile copyFileCompiler
