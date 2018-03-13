(ns eeefff-org-website.core
  #_(:gen-class)
  (:require [eeefff-org-website.pages :as pages]
            [eeefff-org-website.navigation :as navigation]
            [cljs.pprint :refer [pprint]]))

;; (.log js/console "Hey Seymore sup?!")

(defn mount-root []
  (.log js/console "root mounted")
  (let [root-selector "#main-app"
        width (.. (js/$ root-selector)
                  innerWidth)
        height (.. (js/$ root-selector)
                   innerHeight)]
    (navigation/mk-navigation root-selector
                              width
                              height)))


(defn ^:export init []
  (.log js/console "init")
  (.addEventListener js/window
                     "load"
                     (fn []
                       (mount-root))))
