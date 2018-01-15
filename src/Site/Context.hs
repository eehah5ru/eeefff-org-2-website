{-# LANGUAGE OverloadedStrings #-}

module Site.Context where

import Hakyll

import Data.Monoid ((<>), mempty)

import W7W.MultiLang
import W7W.Utils
import W7W.Context


fieldRootUrl =
  field "root_url" getRootUrl
  where
    getRootUrl i = return $ "/" ++ (itemLang i) ++ "/"

siteCtx :: Context String
siteCtx = fieldEnUrl
          <> fieldRuUrl
          <> fieldLang
          <> fieldOtherLang
          <> fieldOtherLangUrl
          <> fieldRootUrl
          <> defaultContext
