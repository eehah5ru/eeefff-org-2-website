{-# LANGUAGE OverloadedStrings #-}

module Site.Projects.Rules where

import Hakyll

import W7W.Rules.StaticPages

import Site.Templates
import Site.Projects.Context

projectsDeps :: Pattern
projectsDeps = ("ru/**/_*.slim" .||. "en/**/_*.slim" .||. "ru/**/_*.md" .||. "en/**/_*.md")

projectsRules = do
  -- deps
  match projectsDeps $ compile getResourceBody

  withProjectsDeps $ do
    staticPandocPageRules rootTpl (Just projectPageTpl) Nothing projectCtx "projects/*.md"
    staticSlimPageRules rootTpl (Just projectPageTpl) Nothing projectCtx "projects/*.slim"

withProjectsDeps rules = do
  deps <- makePatternDependency projectsDeps
  rulesExtraDependencies [deps] rules
