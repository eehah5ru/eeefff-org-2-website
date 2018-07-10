(ns eeefff-org-website.pages
  (:require [cljs.pprint :as pprint]
            [clojure.string :as s]))

(def raw-projects
  [
   {:name "cloud bushes"
    :tags "platform perplex, digital materiality, emotional computing, radical hybridity, digital colonialism, imagined-but-as-yet-not-real, critical interfaces, algorithmic solidarity"}

   {:name "SWS"
    :tags "algorithmic solidarity, communality of alienation, emotional computing, digital colonialism"}
   {:name "myfutures.trade"
    :tags "emotional computing, transactional solidarity, digital colonialism, imagined-but-as-yet-not-real, critical interfaces"}
   {:name "speculative comp club"
    :tags "digital colonialism, real-but-as-yet-unnamed, emotional computing, critical interfaces, algorithmic solidarity"}
   {:name "WHPH"
    :tags "culture synthesizers, paradise politics, weareuntrained"}
   {:name "picnic near the DC"
    :tags "digital materiality, platform perplex, who owns resources?"}
   {:name "exp through IT infrastructure"
    :tags "digital materiality, platform perplex, who owns resources?"}
   {:name "paranoiapp"
    :tags "emotional computing, critical interfaces"}
   {:name "cat scout"
    :tags "weareuntrained, who owns resources?"}
   {:name "psychodata"
    :tags "emotional computing, platform perplex,  critical interfaces, culture synthesizers, weareuntrained"}
   {:name "obj"
    :tags "culture synthesizers, weareuntrained"}
   {:name "Mobile agitator"
    :tags "platform perplex, critical interfaces"}
   {:name "human works as human"
    :tags "emotional computing, digital materiality, critical interfaces, nervous ai, machinic agency, algorithmic solidarity"}
   {:name "machines againsts machines / HZH"
    :tags "emotional computing, critical interfaces, machinic agency, imagined-but-as-yet-not-real"}
   {:name "disco in strong room"
    :tags "fuck discourse let's dance, communality of alienation"}
   {:name "wargaming inspection / whp 2016"
    :tags "data flows, digital materiality, platform perplex, who owns resources?, digital colonialism"}
   {:name "stress test of economic strategies / whp 2016"
    :tags "weareuntrained, emotional computing"}
   {:name "tomatoes in the server room / SCC"
    :tags "digital materiality, platform perplex, who owns resources?, digital colonialism"}
   {:name "progr wanna be / PERV LABOUR ZINE"
    :tags "emotional computing, platform perplex, who owns resources?, weareuntrained, digital colonialism"}
   ])


;;;
;;; tags
;;;
;; (def tags-nodes-data
;;   [
;;    {:name "Algorithmic Solidarity"
;;     :id "algorithmic-solidarity"}
;;    {:name "Communality Of Alienation"
;;     :id "communality-of-alienation"}
;;    {:name "Critical Interfaces"
;;     :id "critical-interfaces"}
;;    {:name "Culture Synthesizers"
;;     :id "culture-synthesizers"}
;;    {:name "Data Flows"
;;     :id "data-flows"}
;;    {:name "Digital Colonialism"
;;     :id "digital-colonialism"}
;;    {:name "Digital Materiality"
;;     :id "digital-materiality"}
;;    {:name "Emotional Computing"
;;     :id "emotional-computing"}
;;    {:name "Fuck Discourse Let's Dance"
;;     :id "fuck-discourse-let's-dance"}
;;    {:name "Imagined-but-as-yet-not-real"
;;     :id "imagined-but-as-yet-not-real"}
;;    {:name "Machinic Agency"
;;     :id "machinic-agency"}
;;    {:name "Nervous Ai"
;;     :id "nervous-ai"}
;;    {:name "Paradise Politics"
;;     :id "paradise-politics"}
;;    {:name "Platform Perplex"
;;     :id "platform-perplex"}
;;    {:name "Radical Hybridity"
;;     :id "radical-hybridity"}
;;    {:name "Real-but-as-yet-unnamed"
;;     :id "real-but-as-yet-unnamed"}
;;    {:name "Transactional Solidarity"
;;     :id "transactional-solidarity"}
;;    {:name "Weareuntrained"
;;     :id "weareuntrained"}
;;    {:name "Who Owns Resources?"
;;     :id "who-owns-resources?"}
;;    ])

;; (def links-data
;;   [{:class :project
;;     :target-id :picnic-near-data-center
;;     :source-id :cat-scout}
;;    {:class :project
;;     :target-id :platform-perplex
;;     :source-id :cat-scout}
;;    {:class :project
;;     :target-id :programmers-wanna-be
;;     :source-id :picnic-near-data-center}
;;    ;; tags
;;    {:class :tag
;;     :target-id :algorithmic-solidarity
;;     :source-id :platform-perplex}
;;    {:class :tag
;;     :target-id :algorithmic-solidarity
;;     :source-id :programmers-wanna-be}
;;    {:class :tag
;;     :target-id :digital-materiality
;;     :source-id :programmers-wanna-be}
;;    ])


;;;
;;;
;;; tags builders
;;;
;;;

;;;
;;; mk tag name
;;;

;;; sanitize tag name
(defn mk-tag-name [n]
  (->> (s/split n #" ")
      (map s/capitalize)
      ;; (interpose " ")
      (s/join " ")))

;;; make tage id from tag name
(defn mk-tag-id [tag-name]
  (s/replace tag-name #" " "-"))

;;; extract tag names as array from project's tags string
(defn extract-tag-names [tags-string]
  (-> tags-string
      (s/split #", ")
      sort
      distinct))

(defn mk-tags-nodes-data []
  (let [tags-string (->> (map :tags
                             raw-projects)
                        (s/join ", "))
        tag-names (extract-tag-names tags-string)]
    (map #(hash-map :id (mk-tag-id %)
                    :name (mk-tag-name %))
         tag-names)))

;;;
;;;
;;; project builders
;;;
;;;
(defn mk-projects-nodes-data []
  (map #(hash-map
         :id (s/replace (:name %) #" " "-")
         :name (:name %)
         :tag-ids (->> (:tags %)
                       extract-tag-names
                       (map mk-tag-id)))
       raw-projects))


(defn mk-links-data []
  [])

;;;
;;; add class to data
;;;
(defn add-class [class xs]
  (map #(assoc % :class class)
       xs))

;;;
;;; add :index to data
;;;
(defn- add-indices [xs]
  (map #(assoc %1 :index %2) xs (range)))

(defn node-by-id [nodes id]
  (first (filter #(= (:id %) id) nodes)))

;;;
;;; added :target and :source indices
;;;
(defn- links-to-indices [links nodes]
  (map #(assoc %
               :target
               (:index (node-by-id nodes (:target-id %)))
               :source
               (:index (node-by-id nodes (:source-id %))))
       links))



(defn nodes []
  (let [project-nodes (add-class :project (mk-projects-nodes-data))
        tags-nodes (add-class :tag (mk-tags-nodes-data))
        all-nodes (concat project-nodes tags-nodes)]
      (add-indices all-nodes)))


(defn projects-only [xs]
  (filter #(= (:class %) :project) xs))


(defn tags-only [xs]
  (filter #(= (:class %) :tag) xs))

(defn filter-nodes [node-ids]
  (filter (fn [x]
            (some #(= (:id x) %)
                  node-ids))
          (nodes)))

(defn tags-for-node [node-id]
  (-> (nodes)
      (node-by-id node-id)
      :tag-ids
      filter-nodes))

(defn nodes-difference [xs ys]
  (filter (fn [x]
            (every? #(not (= (:id x) (:id %)))
                    ys))
          xs))


(defn links []
  (map #(assoc %
               :target
               (:target-id %)
               :source
               (:source-id %))
       (add-indices (mk-links-data))))
