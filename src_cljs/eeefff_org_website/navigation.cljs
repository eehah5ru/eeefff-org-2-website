(ns eeefff-org-website.navigation
  (:require [eeefff-org-website.pages :as pages]
            [cljsjs.d3]
            [cljs.pprint :as pprint]))


;;;
;;;
;;; utils
;;;
;;;

(defn- links-to-indices [links nodes]
  (map #(assoc %
               :target
               (:index (pages/node-by-id nodes (:target %)))
               :source
               (:index (pages/node-by-id nodes (:source %))))
       links))

;;;
;;;
;;; end of utils
;;;
;;;


;;;
;;; SVG
;;;
(defn- build-svg [root width height]
  (.. js/d3
      (select root)
      (select "svg")
      (selectAll "*")
      remove)
  (.. js/d3
      (select root)
      (append "svg")
      (attr "width" "100%")
      (attr "height" "100%")))

;;;
;;; render links in svg
;;;
(defn- build-links [svg js-links]
  (.. svg
      (selectAll ".link")
      (data js-links)
      enter
      (append "line")
      (attr "class" "link")
      (attr "stroke" "cyan")
      (style "stroke-width" 2)))


;;;
;;; render nodes in svg
;;;
(defn- build-nodes [svg forces js-nodes]
  (let [drag-started (fn [d]
                       (cljs.pprint/pprint "drag-started")
                       (.. forces
                           (alpha 0.3)
                           restart)
                       (set! (.-fx d) (.-x d))
                       (set! (.-fy d) (.-y d)))
        drag-dragged (fn [d]
                       (set! (.-fx d) js/d3.event.x)
                       (set! (.-fy d) js/d3.event.y))
        drag-ended (fn [d]
                     (if (not js/d3.event.active)
                       (.. forces
                           (alphaTarget 0)
                           restart))
                     (set! (.-fx d) nil)
                     (set! (.-fy d) nil))]
    (.. svg
        (selectAll ".node")
        (data js-nodes)
        enter
        (append "text")
        (attr "cx" 120)
        (attr "cy" "10em")
        (attr "font-size" "200%")
        (attr "font-family" "monospace")
        (attr "fill" "blue")
        (style "text-decoration" "underline dashed #FF0000")
        (text #(.-name %))
        (on "click" #(cljs.pprint/pprint "clicked"))
        (on "mouseover" (fn []
                          #_(cljs.pprint/pprint "mouseover")
                          (this-as self
                            (.. (js/d3.select self)
                                (style "text-decoration" "underline solid red")
                                (attr "fill" "red")
                                (style "cursor" "pointer")))))
        (on "mouseout" (fn []
                         (this-as self
                           (.. (js/d3.select self)
                               (style "text-decoration" "underline dashed red")
                               (attr "fill" "blue")
                               (style "cursor" "default")))))
        (call (.. (js/d3.drag)
                  (on "start" drag-started)
                  (on "drag" drag-dragged)
                  (on "end" drag-ended)))
        #_(call (.-drag force-layout)))))

;;;
;;; on tick event
;;;
(defn on-tick [link node]
  (fn []
    (cljs.pprint/pprint "ticked")
    (.. link
        (attr "x1" #(.. % -source -x))
        (attr "y1" #(.. % -source -y))
        (attr "x2" #(.. % -target -x))
        (attr "y2" #(.. % -target -y)))
    (.. node
        (attr "transform" #(str "translate(" (.. % -x) "," (.. % -y) ")")))))

;;;
;;; build forces simulation
;;;
(defn- build-forces [width height js-nodes js-links]
  (let [many-body (.. js/d3
                      forceManyBody
                      (strength -1000)
                      ;; (theta 0.1)
                      (distanceMin 200))
        collide (.. js/d3
                    forceCollide
                    (radius 100)
                    (iterations 2))]
    (.. js/d3
        forceSimulation
        (nodes js-nodes)
        (force "charge" many-body)
        (force "center" (js/d3.forceCenter (/ width 2) (/ height 2)))
        (force "link" (js/d3.forceLink js-links))
        (force "collide" collide)
        (force "x" (js/d3.forceX 0))
        (force "y" (js/d3.forceY 0)))))


;;;
;;;
;;; mount navigation to root node
;;;
;;;
(defn mk-navigation [root width height]
  (let [nodes (pages/nodes)
        links (links-to-indices (pages/links) nodes)
        js-nodes (clj->js nodes)
        js-links (clj->js links)

        svg (build-svg root width height)
        forces (build-forces width height js-nodes js-links)
        svg-links (build-links svg js-links)
        svg-nodes (build-nodes svg forces js-nodes)]
    (.on forces "tick"
         (on-tick svg-links svg-nodes))))


;;;
;;;
;;; useful
;;;
;;;
;;; add and remove nodes
;;; http://bl.ocks.org/tgk/6068367
