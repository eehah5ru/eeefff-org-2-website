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
    staticPandocPageRulesM rootTpl (Just projectPageTpl) Nothing (mkProjectCtx caches) Nothing "projects/*.md"
    staticSlimPageRulesM rootTpl (Just projectPageTpl) Nothing (mkProjectCtx caches) Nothing "projects/*.slim"
    staticHtmlPageRulesM rootTpl (Just projectPageTpl) Nothing (mkProjectCtx caches) Nothing "projects/*.html"

    staticPandocPageRulesM rootTpl (Just simplePagePageTpl) Nothing (mkProjectCtx caches) Nothing "pages/*.md"
    staticHtmlPageRulesM rootTpl (Just simplePagePageTpl) Nothing (mkProjectCtx caches) Nothing "pages/*.html"


  --
  -- economic orangery 2021 rules
  --

  -- characters pages
  withProjectsDeps $ do
    staticPandocPageRulesM rootTpl (Just projectPageTpl) (Just "templates/economic-orangery-character.slim") (mkProjectCtx caches) Nothing "projects/economic-orangery/*.md"

  -- game master page
  withProjectsDeps $ do
    staticPandocPageRulesM rootTpl (Just projectPageTpl) (Just "templates/economic-orangery-gm-panel.slim") (mkEconomyOrangeryCtx caches) Nothing "projects/economic-orangery-gm-panel/index.md"


withProjectsDeps rules = do
  deps <- makePatternDependency projectsDeps
  rulesExtraDependencies [deps] rules
