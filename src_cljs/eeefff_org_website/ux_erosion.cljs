(ns eeefff-org-website.ux-erosion
  (:require [oops.core :refer [oget oset! ocall oapply ocall! oapply!
                               oget+ oset!+ ocall+ oapply+ ocall!+ oapply!+]]
            [cljs.pprint :refer [pprint]]
            [clojure.string :as str]))

;; jQuery.fn.random = function() {
;;     var randomIndex = Math.floor(Math.random() * this.length);
;;     return jQuery(this[randomIndex]);
;; };





(def videos
  (str/split "01.mov.mp4 02.mp4.mp4 03.mp4.mp4 04.mp4.mp4 05.mov.mp4 06.mp4.mp4 07.mp4.mp4 08.mp4.mp4 09.mp4.mp4 10.mov.mp4 11.mov.mp4 12.mp4.mp4 13.mp4.mp4"
             #" "))

(defn mk-video-erosion-object [v]
  (->> v
       (assoc {:type :video}
              :url)))
(def phrases
  [{:type :text
    :text "Как поверить в будущее, если оно плохо отрендерено?"
    :css "transform: scale(0.7);"}
   {:type :text
    :text "Утопия с применением плагинов к браузеру и ворованного диджейского софта"}
   {:type :text
    :text "Как оккупировать абстракцию?"}
   {:type :text
    :text "Поглощение на этапе концептулизации"}])

(defn mk-erosion-objects []
  (->> videos
       (map mk-video-erosion-object)
       (concat phrases)))

(def erosion-objects
  (mk-erosion-objects))


;;;
;;; APP STATE
;;;
(def app-state (atom {:width (.-innerWidth js/window)
                      :height (.-innerHeight js/window)
                      :erosion-level 0}))


;;;
;;; control erosion funcs
;;;
(defn is-enough-erosion []
  (> (:erosion-level @app-state) 5))

(defn increase-erosion-level []
  (swap! app-state #(update % :erosion-level inc)))

(defn reset-erosion-level []
  ((swap! app-state #(assoc % :erosion-level 0))))

;;;
;;; end of control erosion funcs
;;;


(defn mk-replacement-video [url]
  (let [position (rand-nth ["relative" "fixed"])
        video-width (+ 200 (rand-int 400))
        video-height (* 8 (/ video-width 16))
        pos-x (rand-int (:width @app-state))
        pos-y (rand-int (:height @app-state))]

    (str "<video class='eroded' onloadeddata=\"this.play();\" autoplay='autoplay' loop muted width=" video-width " height=" video-height " controls style='position:fixed;top:" pos-y "px;left:" pos-x "px;'>"
       "<source class='eroded' src='/data/pi-02/" url "' type='video/mp4'>"
       "</video>")))


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

    (if-not (is-enough-erosion)

      (do
        (pprint (str "nodes found: " (.-length nodes)))

        (.. nodes
            random
            (addClass "eroded")
            (html (mk-replacement (rand-nth erosion-objects))))

        (increase-erosion-level)))))

(defn start-erosion []
  (pprint "started")
  (reset! interval (js/setInterval erode-ux 1000)))

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
  (start-screensaver-delay)
  (reset-erosion-level))


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
