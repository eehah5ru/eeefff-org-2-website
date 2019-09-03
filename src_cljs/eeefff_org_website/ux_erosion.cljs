(ns eeefff-org-website.ux-erosion
  (:require [oops.core :refer [oget oset! ocall oapply ocall! oapply!
                               oget+ oset!+ ocall+ oapply+ ocall!+ oapply!+]]
            [cljs.pprint :refer [pprint]]))

;; jQuery.fn.random = function() {
;;     var randomIndex = Math.floor(Math.random() * this.length);
;;     return jQuery(this[randomIndex]);
;; };


(def phrases
  [{:type :text
    :text "Как поверить в будущее, если оно плохо отрендерено?"
    :css "transform: scale(0.7);"}
   {:type :text
    :text "Утопия с применением плагинов к браузеру и ворованного диджейского софта"}
   {:type :text
    :text "Как оккупировать абстракцию?"}
   {:type :text
    :text "Поглощение на этапе концептулизации"}
   {:type :video
    :url "01.mp4.mp4"}
   {:type :video
    :url "02.mp4.mp4"}
   {:type :video
    :url "03.mp4.mp4"}
   {:type :video
    :url "04.mp4.mp4"}
   {:type :video
    :url "05.mp4.mp4"}])

(defn mk-replacement-video [url]
  (str "<video class='eroded' onloadeddata=\"this.play();\" autoplay='autoplay' loop muted width=380 height=240 controls>"
       "<source class='eroded' src='/data/parasite-interaces/" url "' type='video/mp4'>"
       "</video>"))


(defn mk-replacement-text [phrase]
  (let [font-size (+ 20
                     (* 50 (Math/random)))]
    (str "<span class=\"eroded\" style='font-size: "
         font-size
         "px';>"
         phrase
         "</span>")))


(defn mk-replacement [src]
  (case (:type src)
    :text (mk-replacement-text (:text src))
    :video (mk-replacement-video (:url src))
    ;; missing type
    (throw (js/Error. (src "Unknown replacement type: " (:type src))))))


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
  (let [selector "body *:not(.eroded)"
        js-doc (js/jQuery js/document)
        find-fn (first (shuffle ["deepest" "deepest" "deepest" "find"]))

        nodes (.. (js-invoke js-doc find-fn selector)
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
