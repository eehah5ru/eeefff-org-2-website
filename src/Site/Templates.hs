{-# LANGUAGE OverloadedStrings #-}

module Site.Templates where

import Hakyll

rootTpl :: Identifier
rootTpl = "templates/default.html"

indexPageTpl :: Identifier
indexPageTpl = "templates/index.html"

projectPageTpl :: Identifier
projectPageTpl = "templates/project.html"
