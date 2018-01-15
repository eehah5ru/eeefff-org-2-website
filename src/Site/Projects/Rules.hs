{-# LANGUAGE OverloadedStrings #-}

module Site.Projects.Rules where

import Hakyll

import W7W.Rules.StaticPages

import Site.Templates
import Site.Projects.Context


projectsRules = do
  staticPandocPageRules rootTpl projectPageTpl projectCtx "projects/*.md"
  staticSlimPageRules rootTpl projectPageTpl projectCtx "projects/*.slim"
