{-# LANGUAGE OverloadedStrings #-}
module Site.Flow.Rules where

import Hakyll

import W7W.MultiLang
import W7W.Compilers.Slim
import W7W.Compilers.Markdown
import W7W.Typography

import qualified W7W.Cache as Cache

import Site.Context
import Site.Templates

import Site.Flow.Compiler
import Site.Flow.Context

flowIndexRules :: Cache.Caches -> Rules ()
flowIndexRules c = do
  matchMultiLang rules' rules' Nothing "flow/index.md"

  where
    rules' locale =
      markdownPageRules $ \x-> do
        ctx <- mkFlowIndexCtx c
        renderFlowIndex ctx x

flowBlockRules :: Cache.Caches -> Rules ()
flowBlockRules c = do
  matchMultiLang rules' rules' (Just ["flow/index.md"]) "flow/*.md"

  where
    rules' locale =
      markdownPageRules $ \x-> do
        ctx <- mkFlowItemCtx c
        renderFlowBlock ctx x
