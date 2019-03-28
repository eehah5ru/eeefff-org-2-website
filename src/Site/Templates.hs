{-# LANGUAGE OverloadedStrings #-}

module Site.Templates where

import Hakyll

rootTpl :: Identifier
rootTpl = "templates/default.html"

indexPageTpl :: Identifier
indexPageTpl = "templates/index.html"

aboutPageTpl :: Identifier
aboutPageTpl = "templates/about.slim"

projectPageTpl :: Identifier
projectPageTpl = "templates/project.html"
