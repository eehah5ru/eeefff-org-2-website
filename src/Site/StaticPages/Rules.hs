{-# LANGUAGE OverloadedStrings #-}

module Site.StaticPages.Rules where

import Hakyll

import W7W.Rules.StaticPages

import Site.Templates
import Site.StaticPages.Context

staticPagesRules caches = do
  indexPageRules caches
  aboutPageRules caches


indexPageRules caches = do
  staticHtmlPageRulesM rootTpl (Just indexPageTpl) Nothing (mkStaticPageCtx caches) "index.html"

aboutPageRules caches = do
  staticPandocPageRulesM rootTpl (Just aboutPageTpl) Nothing (mkStaticPageCtx caches) "about.md"
