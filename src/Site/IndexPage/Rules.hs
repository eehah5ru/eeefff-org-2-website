{-# LANGUAGE OverloadedStrings #-}

module Site.IndexPage.Rules where

import Hakyll

import W7W.Rules.StaticPages

import Site.Templates
import Site.IndexPage.Context

indexPageRules caches = do
  staticHtmlPageRulesM rootTpl (Just indexPageTpl) Nothing (mkIndexCtx caches) "index.html"
