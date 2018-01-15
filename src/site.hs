--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}

import Data.Monoid (mappend, (<>))
import Control.Monad ((>=>))
import Hakyll
import Hakyll.Web.Sass (sassCompilerWith)
import Hakyll.Core.Configuration (Configuration, previewPort)
import Data.Default (def)
import qualified Text.Sass.Options as SO

import qualified W7W.Config as W7WConfig

import W7W.Rules.Templates
import W7W.Rules.Assets
import W7W.Compilers.Slim -- for platform perplex

import Site.IndexPage.Rules
import Site.Projects.Rules

import Site.Projects.Context -- for platform perplex
--------------------------------------------------------------------------------

config :: Configuration
config = W7WConfig.config { previewPort = 8111 }


main :: IO ()
main =
  hakyllWith config $
  do

     --
     -- templates
     --
     templatesRules

     --
     -- assets
     --
     imagesRules
     fontsRules
     dataRules
     cssAndSassRules
     jsRules

     --
     -- deps
     --
     -- slim partials for deps
     match ("ru/**/_*.slim" .||. "en/**/_*.slim") $ compile getResourceBody

     --
     -- static pages
     --
     -- staticPagesRules

     --
     -- projects and posts
     --
     projectsRules
     platformPerplexRules

     --
     -- index page
     --
     indexPageRules


--------------------------------------------------------------------------------


platformPerplexRules = do
  match ("platform-perplex/*.html" .&&. (complement "platform-perplex/index.html")) $ compile templateCompiler

  deps <- makePatternDependency ("platform-perplex/*.html" .&&. (complement "platform-perplex/index.html"))

  rulesExtraDependencies [deps] $ match "platform-perplex/index.slim" $ do
    route $ setExtension "html"
    compile $ slimCompiler
      >>= applyAsTemplate projectCtx
      >>= loadAndApplyTemplate "templates/default.html" projectCtx
      >>= relativizeUrls


-- projectsRules =
--   do match "projects/*.md" $
--        do route $ setExtension "html"
--           compile $ pandocCompiler
--             >>= loadAndApplyTemplate "templates/project.html" projectCtx
--             >>= loadAndApplyTemplate "templates/default.html" projectCtx
--             >>= relativizeUrls

--      match "projects/*.slim" $
--            do route $ setExtension "html"
--               compile $ slimCompiler
--                 >>= loadAndApplyTemplate "templates/project.html" projectCtx
--                 >>= loadAndApplyTemplate "templates/default.html" projectCtx
                -- >>= relativizeUrls

-- compilers

-- coffee :: Compiler (Item String)
-- coffee = getResourceString >>= withItemBody processCoffee
--   where
--     processCoffee = unixFilter "coffee" ["-c", "-s"] >=>
--                     unixFilter "yuicompressor" ["--type", "js"]

--
--
-- contexts
--
--

-- projectCtx = defaultContext

-- indexCtx = projectsListCtx `mappend` defaultContext

-- projectsInfo = [ ("Paranoiapp", "https://paranoiapp.net")
--                ,("OBJ", "http://ooooobj.org")
--                ,("Cat-scout", "/projects/cat-scout.html")
--                ,("Psychodata", "/projects/psychodata.html")]


-- projectsListCtx = listField "projects"
--                             ((field "project-name" (return . fst . itemBody))
--                              <> (field "project-link" (return . snd . itemBody)))
--                             (sequence . map makeItem $ projectsInfo)
