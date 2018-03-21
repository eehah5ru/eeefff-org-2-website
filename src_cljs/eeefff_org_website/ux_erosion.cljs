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
   "Поглощение на этапе концептулизации"])

(defn mk-replacement [phrase]
  (let [font-size (+ 20
                     (* 50 (Math/random)))]
    (str "<span class=\"eroded\" style='font-size: "
         font-size
         "px';>"
         phrase
         "</span>")))

(defonce interval (atom 0))

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
  (.. (js/jQuery "body *:not(.eroded)")
      random
      (addClass "eroded")
      (html (mk-replacement (rand-nth phrases)))))

(defn start-erosion []
  (reset! interval (js/setInterval erode-ux 500)))
