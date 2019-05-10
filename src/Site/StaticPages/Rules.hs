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
  staticHtmlPageRulesM rootTpl Nothing Nothing (mkStaticPageCtx caches) "*.html"

mdPageRules caches = do
  staticPandocPageRulesM rootTpl Nothing Nothing (mkStaticPageCtx caches) "*.md"

slimPageRules caches = do
  staticSlimPageRulesM rootTpl Nothing Nothing (mkStaticPageCtx caches) "*.slim"
