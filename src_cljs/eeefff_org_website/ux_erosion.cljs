(ns eeefff-org-website.ux-erosion
  (:require [oops.core :refer [oget oset! ocall oapply ocall! oapply!
                               oget+ oset!+ ocall+ oapply+ ocall!+ oapply!+]]
            [cljs.pprint :refer [pprint]]))

;; jQuery.fn.random = function() {
;;     var randomIndex = Math.floor(Math.random() * this.length);
;;     return jQuery(this[randomIndex]);
;; };

(def phrases
  ["Как поверить в будущее, если оно плохо отрендерено?"
   "Утопия с применением плагинов к браузеру и ворованного диджейского софта"
   "Как оккупировать абстракцию?"
   "Поглощение на этапе концептулизации"
   "<img width=300 height=300 src=''></img>"])

(defn mk-replacement [phrase]
  (let [font-size (+ 20
                     (* 50 (Math/random)))]
    (str "<span class=\"eroded\" style='font-size: "
         font-size
         "px';>"
         phrase
         "</span>")))

(defonce interval (atom 0))

(defonce timeout (atom 0))

(defn stop-erosion []
  (pprint "stopped")
  (js/clearInterval @interval))


(defn declare-jquery-random []
  (oset! js/jQuery
         "!fn.!random"
         (fn []
           (this-as self
             (let [random-index (Math/floor (* (Math/random)
                                               (.-length self)))]
               (if (> (.-length self) 0)
                 (js/jQuery (oget+ self (identity (str random-index))))
                 (do
                   (stop-erosion)
                   (js/jQuery (clj->js [])))))))))


(defn erode-ux []
  (let [nodes (.. (js/jQuery js/document)
                  (deepest "body *:not(.eroded)")
                  (filter (fn [i, e]
                            (.. (js/jQuery e)
                                (visible true)))))]

    (pprint (str "nodes found: " (.-length nodes)))

    (.. nodes
        random
        (addClass "eroded")
        (html (mk-replacement (rand-nth phrases))))))

(defn start-erosion []
  (pprint "started")
  (reset! interval (js/setInterval erode-ux 500)))

(defn stop-screensaver-delay []
  (pprint "clearing erosion delay")
  (js/clearTimeout @timeout))

(defn start-screensaver-delay []
  (pprint "setting erosion delay")

  (reset! timeout
          (js/setTimeout start-erosion 10000)))

(defn restart-screensaver []
  (stop-erosion)
  (stop-screensaver-delay)
  (start-screensaver-delay))


(defn setup-erosion []
  (start-screensaver-delay)

  (.. (js/jQuery js/document)
      (mousemove (fn []
                   (pprint "mousemove")
                   (restart-screensaver))))

  (.. (js/jQuery js/window)
      (scroll (fn []
                (pprint "onscroll")
                (restart-screensaver)))))
