--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}


import Data.Monoid (mappend, (<>))
import Control.Monad ((>=>))
import Hakyll
import Hakyll.Web.Sass (sassCompilerWith)
import Hakyll.Core.Configuration (Configuration, previewPort)
import Data.Default (def)
import qualified Text.Sass.Options as SO

import Data.List (isPrefixOf)

import qualified W7W.Cache as Cache
import qualified W7W.Config as W7WConfig

import W7W.Rules.Templates
import W7W.Rules.Assets
import W7W.Compilers.Slim -- for platform perplex

import W7W.Pictures.Rules

import Site.StaticPages.Rules
import Site.Projects.Rules


import Site.Documenta

import Site.Flow.Rules

import Site.Projects.Context -- for platform perplex
--------------------------------------------------------------------------------

ignoredFiles :: FilePath -- ^
  -> Bool
ignoredFiles f =
  any (\x -> x f)
      [ (ignoreFile defaultConfiguration)
      , ignoreTarget
      , ignoreResources]
  where
    ignoreTarget = isPrefixOf "target"
    ignoreResources = isPrefixOf "resources"

config :: Configuration
config = W7WConfig.config { previewPort = 8111
                          , ignoreFile = ignoredFiles}


picturesConfig =
  copyAllPicturesRulesConfig {othersStrategy = PicResizeStrategy (1280, 1280)}

main :: IO ()
main = do
  caches <- Cache.newCaches

  hakyllWith config' $
    do

       --
       -- templates
       --
       templatesRules

       --
       -- assets
       --
       imagesRules
       picturesRules picturesConfig "pictures"
       fontsRules
       dataRules

       cssAndSassRules
         ("css/_*.scss" .||. "css/**/_*.scss")
         [ "css/app.scss"
         , "css/erosion-machine-timeline.scss"
         , "css/pages/*.scss"]

       jsRules

       --
       -- deps
       --
       -- slim partials for deps

       --
       -- static pages
       --
       -- staticPagesRules

       --
       -- projects and posts
       --
       projectsRules caches
       platformPerplexRules caches

       documentaRules caches

       --
       -- staticpages
       --
       staticPagesRules caches

       --
       -- flow pages
       --
       flowBlockRules caches
       flowIndexRules caches

  where
    config' = config {providerDirectory = "web"}

--------------------------------------------------------------------------------


platformPerplexRules caches = do
  match ("platform-perplex/*.html" .&&. (complement "platform-perplex/index.html")) $ compile templateCompiler

  deps <- makePatternDependency ("platform-perplex/*.html" .&&. (complement "platform-perplex/index.html"))

  rulesExtraDependencies [deps] $ match "platform-perplex/index.slim" $ do
    route $ setExtension "html"
    compile $ do
      c <- mkProjectCtx caches
      slimCompiler
        >>= applyAsTemplate c
        >>= loadAndApplyTemplate "templates/default.html" c
        >>= relativizeUrls
