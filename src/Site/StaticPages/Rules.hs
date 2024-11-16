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
  rules (Just ["index.html"]) "*.html"
  rules Nothing "index.html"
  where
    rules = staticHtmlPageRulesM rootTpl Nothing Nothing (mkStaticPageCtx caches)

mdPageRules caches = do
  rules (Just ["index.md"]) "*.md"
  rules Nothing "index.md"
  where
    rules = staticPandocPageRulesM rootTpl Nothing Nothing (mkStaticPageCtx caches)

slimPageRules caches = do
  rules (Just ["index.slim"]) "*.slim"
  rules Nothing "index.slim"
  where
    rules = staticSlimPageRulesM rootTpl Nothing Nothing (mkStaticPageCtx caches)
