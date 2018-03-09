(ns eeefff-org-website.pages
  (:require [cljs.pprint :as pprint]))

(def nodes-data
  [
   ;;
   ;; projects
   ;;
   {:id :picnic-near-data-center
    :class :project
    :name "Picnic near the data center"}
   {:id :platform-perplex
    :class :project
    :name "Platform Perplex"}
   {:id :programmers-wanna-be
    :name "Programmers wanna be"
    :class :project}
   {:id :cat-scout
    :name "Cat scout"
    :class :project}
   ;;
   ;; tags
   ;;
   {:id :algorithmic-solidarity
    :class :tag
    :name "Algorithmic solidarity"}
   {:id :digital-materiality
    :class :tag
    :name "Digital Materiality"}])

(def links-data
  [{:class :project
    :target-id :picnic-near-data-center
    :source-id :cat-scout}
   {:class :project
    :target-id :platform-perplex
    :source-id :cat-scout}
   {:class :project
    :target-id :programmers-wanna-be
    :source-id :picnic-near-data-center}
   ;; tags
   {:class :tag
    :target-id :algorithmic-solidarity
    :source-id :platform-perplex}
   {:class :tag
    :target-id :algorithmic-solidarity
    :source-id :programmers-wanna-be}
   {:class :tag
    :target-id :digital-materiality
    :source-id :programmers-wanna-be}
   ])

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
  (add-indices nodes-data))

(defn projects-only [xs]
  (filter #(= (:class %) :project) xs))

(defn tags-only [xs]
  (filter #(= (:class %) :tag) xs))

(defn links []
  (map #(assoc %
               :target
               (:target-id %)
               :source
               (:source-id %))
       (add-indices links-data)))
