{-# LANGUAGE OverloadedStrings #-}

module Site.Projects.Rules where

import Hakyll

import W7W.Rules.StaticPages

import Site.Templates
import Site.Projects.Context
import qualified W7W.Cache as Cache

import Site.Projects.EconomicOrangery

projectsDeps :: Pattern
projectsDeps = ("ru/**/_*.slim" .||. "en/**/_*.slim" .||. "ru/**/_*.md" .||. "en/**/_*.md" .||. "ru/**/_*.html" .||. "en/**/_*.html" .||. "ru/**/_*.raw" .||. "en/**/_*.raw")


projectsRules caches = do
  -- deps
  match projectsDeps $ compile getResourceBody

  withProjectsDeps $ do
    staticPandocPageRulesM rootTpl (Just projectPageTpl) Nothing (mkProjectCtx caches) "projects/*.md" Nothing
    staticSlimPageRulesM rootTpl (Just projectPageTpl) Nothing (mkProjectCtx caches) "projects/*.slim" Nothing
    staticHtmlPageRulesM rootTpl (Just projectPageTpl) Nothing (mkProjectCtx caches) "projects/*.html" Nothing

  --
  -- economic orangery 2021 rules
  --

  -- characters pages
  withProjectsDeps $ do
    staticPandocPageRulesM rootTpl (Just projectPageTpl) (Just "templates/economic-orangery-character.slim") (mkProjectCtx caches) "projects/economic-orangery/*.md" Nothing

  -- game master page
  withProjectsDeps $ do
    staticPandocPageRulesM rootTpl (Just projectPageTpl) (Just "templates/economic-orangery-gm-panel.slim") (mkEconomyOrangeryCtx caches) "projects/economic-orangery-gm-panel/index.md" Nothing


withProjectsDeps rules = do
  deps <- makePatternDependency projectsDeps
  rulesExtraDependencies [deps] rules
