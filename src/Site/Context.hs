{-# LANGUAGE OverloadedStrings #-}

module Site.Context where

import Hakyll

import Data.Monoid ((<>), mempty)

import W7W.MultiLang
import W7W.Utils
import W7W.Context

import W7W.Cache

fieldRootUrl =
  field "root_url" getRootUrl
  where
    getRootUrl i = return $ "/" ++ (itemLang i) ++ "/"

fieldHideLangSwitch =
  boolFieldM "hideLangSwitch" hideLangSwitch
  where
    hideLangSwitch i = do
      mF <- getMetadataField (itemIdentifier i) "hideLangSwitch"
      case mF of
        Just "true" -> return True
        -- Just "false" -> return False
        -- Just _ -> return False
        _ -> return False

fieldHideMenu =
  boolFieldM "hideMenu" hideMenu
  where
    hideMenu i = do
      mF <- getMetadataField (itemIdentifier i) "hideMenu"
      case mF  of
        Just "true" -> return True
        _ -> return False

mkSiteCtx :: Caches -> Compiler (Context String)
mkSiteCtx caches = do
    r <- mkFieldRevision caches
    return $ fieldEnUrl
             <> fieldRuUrl
             <> fieldLang
             <> fieldOtherLang
             <> fieldOtherLangUrl
             <> fieldCanonicalName
             <> fieldRootUrl
             <> r
             <> fieldHideLangSwitch
             <> fieldHideMenu
             <> defaultContext
