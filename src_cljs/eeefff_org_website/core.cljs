(ns eeefff-org-website.core
  #_(:gen-class)
  (:require [eeefff-org-website.pages :as pages]
            [eeefff-org-website.navigation :as navigation]))

;; (.log js/console "Hey Seymore sup?!")

(defn mount-root []
  (.log js/console "root mounted")
  (navigation/mk-navigation ".main-app" 640 480))


(defn ^:export init []
  (.log js/console "init")
  (.addEventListener js/window
                     "load"
                     (fn []
                       (mount-root))))
