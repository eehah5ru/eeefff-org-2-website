(ns eeefff-org-website.core
  #_(:gen-class)
  (:require
   [re-frame.core :as re-frame :refer [dispatch subscribe console]]
   [reagent.core :as reagent]
   [eeefff-org-website.pages :as pages]
   [eeefff-org-website.navigation :as navigation]
   [cljs.pprint :refer [pprint]]

   ))

;; (.log js/console "Hey Seymore sup?!")

(def js-player (atom nil))

(defn on-ready [event]
  (js/console.log "ready"))

(defn on-state-changed [event]
  (js/console.log "status-changed"))

(defn mount-root []
  (.log js/console "root mounted")

  ;;
  ;; async load youtube iframe api
  ;;
  (let [tag (.createElement js/document "script")
        _ (set! (.-src tag) "https://www.youtube.com/iframe_api")
        first-script-tag (first (array-seq (.getElementsByTagName js/document "script")))]
    (.insertBefore (.-parentNode first-script-tag) tag first-script-tag))


  (letfn [(on-ready [event]
            (js/console.log "ready"))

          (on-state-changed [event]
            (.log js/console "state-changed"))]

    (set! js/onYouTubeIframeAPIReady
        (fn []
          (.log js/console "on youtube api ready")
          (reset! js-player (js/YT.Player.
                             "hwash-video"
                             (clj->js {:height 390
                                       :width 640
                                       :videoId "Fn7OmbgrXWg"
                                       :events {:onReady on-ready
                                                :onStateChange on-state-changed}})))

          (.log js/console "exit youtube api ready")))))

#_(let [root-selector "#main-app"
        width (.. (js/$ root-selector)
                  innerWidth)
        height (.. (js/$ root-selector)
                   innerHeight)]
    (navigation/mk-navigation root-selector
                              width
                              height))

(defn ^:export init []
  (.log js/console "init")
  (.addEventListener
   js/window
   "load"
   (fn []
     (mount-root)

     (.. (js/$ "article a.cue")
         (click (fn [e]
                  (console :log :cue-clicked)

                  (let [target (js/$ (.-target e))
                        start-pos (.data target "start")
                        end-pos (.data target "start")]
                    (.log js/console (.data target "start"))

                    (.seekTo @js-player start-pos)
                    (.playVideo @js-player))))))))
