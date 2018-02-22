{-# LANGUAGE OverloadedStrings #-}

module Site.Documenta where

import Hakyll

import W7W.Compilers.Slim
import W7W.Rules.StaticPages

import Site.Templates
import Site.Context
import W7W.Utils

documentaRules = do
  match "documenta/*.slim" $ do
    slimPageRules compilers
  where
    compilers x =
      applyAsTemplate siteCtx x
        >>= applyCustomPageTemplateSnapshot siteCtx
        >>= applyTemplateSnapshot rootTpl siteCtx
