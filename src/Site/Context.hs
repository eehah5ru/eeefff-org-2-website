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

functionIncludeFile =
  functionField "includeFile" includeFile

  where
    getFileContent p = do
      (loadBody (fromFilePath p) :: Compiler String)
    includeFile [] _ = error "includeFile: missing file path"
    includeFile (p:[]) _ = getFileContent p
    includeFile _ _ = error "includeFile: Usage includeFile(filePath)"
siteCtx :: Context String
siteCtx = fieldEnUrl
          <> fieldRuUrl
          <> fieldLang
          <> fieldOtherLang
          <> fieldOtherLangUrl
          <> fieldCanonicalName
          <> fieldRootUrl
          <> fieldRevision
          <> fieldHideLangSwitch
          <> fieldHideMenu
          <> functionIncludeFile
          <> defaultContext
