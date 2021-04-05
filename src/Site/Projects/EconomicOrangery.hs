{-# LANGUAGE OverloadedStrings #-}

module Site.Projects.EconomicOrangery where

import Data.Binary
import Data.Typeable

import Hakyll

import W7W.Rules.StaticPages

import Site.Templates
import Site.Projects.Context
import W7W.MultiLang

import qualified W7W.Cache as Cache

import Site.Context
import Site.Projects.Context


charactersPattern :: Locale -> Pattern
charactersPattern l = (fromGlob . localizePath l $ "projects/economic-orangery/*.md")

loadCharactersItems :: (Binary a, Typeable a) => Locale -> Compiler [Item a]
loadCharactersItems l = do
  loadAll $ charactersPattern l

mkCharacterItemsField :: Cache.Caches -> Compiler (Context String)
mkCharacterItemsField c = do
  ctx <- mkCharacterItemCtx c
  return $ listFieldWith "flowItems" ctx flowItems

  where
    flowItems i = loadAllSnapshots (charactersPattern (itemLocale i)) "content"


mkEconomyOrangeryCtx :: Cache.Caches -> Compiler (Context String)
mkEconomyOrangeryCtx c = do
  ctx <- mkProjectCtx c
  characterItems <- mkCharacterItemsField c
  return $ characterItems <> ctx


mkCharacterItemCtx :: Cache.Caches -> Compiler (Context String)
mkCharacterItemCtx c = do
  mkProjectCtx c
