(ns eeefff-org-website.navigation
  (:require [eeefff-org-website.pages :as pages]
            [cljsjs.d3]
            [cljs.pprint :refer [pprint]]))


;;;
;;;
;;; utils
;;;
;;;

;;;
;;;
;;; end of utils
;;;
;;;

;;;
;;;
;;; state
;;;
;;;

;; (def state (clj->js {:svg nil
;;                      :svg-nodes nil
;;                      :svg-links nil}))
;; (def _svg-nodes nil)
;; (def _svg-links nil)



;; (defn with-svg-nodes [f]
;;   (let [x @_svg-nodes
;;         y (f x)]
;;     (reset!)))

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


(defn- svg-nodes [svg]
  (.. svg
      (selectAll ".node")))


(defn- svg-links [svg]
  (.. svg
      (selectAll ".link")))


(defn- render-links [svg js-links]
  ;; (set! (.-svg-links state) (.data (.-svg-links state) js-links))

  ;; (pprint _svg-links)

  (let [links-data (.. (svg-links svg)
                       (data js-links))]
    (.. links-data
        enter
        (append "line")           ; why node?
        (attr "class" "link")
        (attr "stroke" "cyan")
        (style "stroke-width" 2)))

  #_(.. _svg-links
      exit
      remove))

(defn- render-nodes [svg js-nodes render]
  ;; (set! (.-svg-nodes state) (.data (.-svg-nodes state) js-nodes))

  ;; (pprint (.nodes forces))

  (let [nodes-data (.. (svg-nodes svg)
                       (data js-nodes))]
      (.. nodes-data
       enter
       (append "text")
       (attr "class" "node")
       ;; (attr "cx" "0")
       ;; (attr "cy" "10em")
       (attr "font-size" "200%")
       (attr "font-family" "monospace")
       (attr "fill" "blue")
       (style "text-decoration" "underline dashed #FF0000")
       (text #(.-name %))
       #_(on "click" (fn [d]
                       (let [tags (pages/tags-only (pages/nodes))
                             new-nodes (concat (js->clj (.nodes forces)) tags)]
                         (pprint "clicked")
                         #_(pprint d)
                         (.nodes forces (clj->js new-nodes))
                         (.tick forces)
                         (render)
                         )))
       ;; exit
       ;; remove
                                        ; events here!
       ))

  #_(.. _svg-nodes
      exit
      remove))



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
                       (pprint "drag-started")
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
        (insert "text")
        (attr "cx" 120)
        (attr "cy" "10em")
        (attr "font-size" "200%")
        (attr "font-family" "monospace")
        (attr "fill" "blue")
        (style "text-decoration" "underline dashed #FF0000")
        (text #(.-name %))
        (on "click" #(pprint "clicked"))
        (on "mouseover"
            (fn []
              #_(pprint "mouseover")
              (let [forced-nodes (.nodes forces)]
                #_(pprint all-projects)

                ;; (mk-navigation ".main-app"
                ;;                640
                ;;                480
                ;;                all-projects
                ;;                (links-to-indices (pages/links) (pages/nodes)))

               (this-as self
                 (.. (js/d3.select self)
                     (style "text-decoration" "underline solid red")
                     (attr "fill" "red")
                     (style "cursor" "pointer"))))))
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
(defn on-tick [svg]
  (fn []
    (pprint "ticked")
    (.. (svg-links svg)
        (attr "x1" #(.. % -source -x))
        (attr "y1" #(.. % -source -y))
        (attr "x2" #(.. % -target -x))
        (attr "y2" #(.. % -target -y)))

    (.. (svg-nodes svg)
        (attr "transform" #(str "translate(" (.. % -x) "," (.. % -y) ")")))
    ))

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
        (forceSimulation js-nodes)
        ;; (nodes js-nodes)
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
  (let [nodes (pages/projects-only (pages/nodes))
        links (pages/projects-only (pages/links))
        js-nodes (clj->js nodes)
        js-links (clj->js links)

        svg (build-svg root width height)

        ;; svg-nodes (build-svg-nodes svg)
        ;; svg-links (build-svg-links svg)

        forces (build-forces width height js-nodes js-links)]

    (letfn [(render []
              (render-links svg js-links)
              (render-nodes svg js-nodes render)
              )]
      ;; (.restart forces)

      ;; (set! (.-svg state) svg)
      ;; (set! (.-svg-nodes state) (svg-nodes svg))
      ;; (set! (.-svg-links state) (svg-links svg))

      ;; (render-links svg-links js-links)
      ;; (render-nodes svg-nodes js-nodes render)
      (render)
      (.on forces "tick"
           (on-tick svg)))
    ))



;;;
;;;
;;; useful
;;;
;;;
;;; add and remove nodes
;;; http://bl.ocks.org/tgk/6068367
