{-# LANGUAGE OverloadedStrings #-}

module Site.StaticPages.Rules where

import Hakyll

import W7W.Rules.StaticPages

import Site.Templates
import Site.StaticPages.Context

staticPagesRules caches = do
  htmlPageRules caches
  mdPageRules caches
  slimPageRules caches


htmlPageRules caches = do
  rules "*.html" (Just ["index.html"])
  rules "index.html" Nothing
  where
    rules = staticHtmlPageRulesM rootTpl Nothing Nothing (mkStaticPageCtx caches)

mdPageRules caches = do
  rules "*.md" (Just ["index.md"])
  rules "index.md" Nothing
  where
    rules = staticPandocPageRulesM rootTpl Nothing Nothing (mkStaticPageCtx caches)

slimPageRules caches = do
  rules "*.slim" (Just ["index.slim"])
  rules "index.slim" Nothing
  where
    rules = staticSlimPageRulesM rootTpl Nothing Nothing (mkStaticPageCtx caches)
