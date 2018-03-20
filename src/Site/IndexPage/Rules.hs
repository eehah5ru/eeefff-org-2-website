{-# LANGUAGE OverloadedStrings #-}

module Site.IndexPage.Rules where

import Hakyll

import W7W.Rules.StaticPages

import Site.Templates
import Site.IndexPage.Context

indexPageRules = do
  staticHtmlPageRules rootTpl (Just indexPageTpl) Nothing indexCtx "index.html"
