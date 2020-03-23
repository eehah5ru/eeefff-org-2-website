{-# LANGUAGE OverloadedStrings #-}
module Site.Flow.Compiler where

import Hakyll

import Site.Templates
import Site.Context

-- import Site.Flow.Context

renderFlowIndex ctx x = do
  applyAsTemplate ctx x
  >>= loadAndApplyTemplate "templates/flow.slim" ctx
  >>= loadAndApplyTemplate rootTpl ctx

renderFlowBlock ctx x = do
  applyAsTemplate ctx x
  >>= loadAndApplyTemplate "templates/flow-block.slim" ctx
  >>= saveSnapshot "content"
  >>= loadAndApplyTemplate rootTpl ctx

renderFlowBlocks ctx blocks = do
  tpl <- loadBody "templates/flow-block.slim"
  applyTemplateList tpl ctx blocks
