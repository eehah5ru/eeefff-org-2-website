{-# LANGUAGE OverloadedStrings #-}

module Site.Projects.Rules where

import Hakyll

import W7W.Rules.StaticPages

import Site.Templates
import Site.Projects.Context
import qualified W7W.Cache as Cache

projectsDeps :: Pattern
projectsDeps = ("ru/**/_*.slim" .||. "en/**/_*.slim" .||. "ru/**/_*.md" .||. "en/**/_*.md")


projectsRules caches = do
  -- deps
  match projectsDeps $ compile getResourceBody

  withProjectsDeps $ do
    staticPandocPageRulesM rootTpl (Just projectPageTpl) Nothing (mkProjectCtx caches) "projects/*.md"
    staticSlimPageRulesM rootTpl (Just projectPageTpl) Nothing (mkProjectCtx caches) "projects/*.slim"

withProjectsDeps rules = do
  deps <- makePatternDependency projectsDeps
  rulesExtraDependencies [deps] rules
