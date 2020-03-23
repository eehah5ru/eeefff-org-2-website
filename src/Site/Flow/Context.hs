{-# LANGUAGE OverloadedStrings #-}
module Site.Flow.Context where

import Data.Binary
import Data.Typeable

import Hakyll

import W7W.MultiLang
import qualified W7W.Cache as Cache

import Site.Flow.Compiler

import Site.Context

flowBlockPattern :: Locale -> Pattern
flowBlockPattern l = (fromGlob . localizePath l $ "flow/*.md") .&&. (complement (fromGlob . localizePath l $ "flow/index.md"))


loadFlowItems :: (Binary a, Typeable a) => Locale -> Compiler [Item a]
loadFlowItems l = do
  loadAll $ flowBlockPattern l


mkFlowItemsField :: Cache.Caches -> Compiler (Context String)
mkFlowItemsField c = do
  ctx <- mkFlowItemCtx c
  return $ listFieldWith "flowItems" ctx flowItems

  where
    flowItems i = loadAllSnapshots (flowBlockPattern (itemLocale i)) "content"

numFlowItemsField :: Context String
numFlowItemsField = field "numFlowItems" f'
  where
    f' i  = do
      items <- loadFlowItems (itemLocale i) :: Compiler [Item String]
      return . show $ length items

mkFlowBlocksField :: Cache.Caches -> Compiler (Context String)
mkFlowBlocksField c = return $ field "flowBlocks" f'
  where
    f' i = do
      ctx <- mkFlowItemCtx c
      (loadFlowItems (itemLocale i) :: Compiler [Item String])
        >>= renderFlowBlocks ctx

mkFlowIndexCtx :: Cache.Caches -> Compiler (Context String)
mkFlowIndexCtx c = do
  ctx <- mkSiteCtx c
  flowItems <- mkFlowItemsField c
  flowBlocks <- mkFlowBlocksField c
  return $ flowItems <> numFlowItemsField <> flowBlocks <> ctx


mkFlowItemCtx :: Cache.Caches -> Compiler (Context String)
mkFlowItemCtx c = do
  ctx <- mkSiteCtx c
  return ctx
