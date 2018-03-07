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
  [{:target :picnic-near-data-center
    :source :cat-scout}
   {:target :platform-perplex
    :source :cat-scout}
   {:target :programmers-wanna-be
    :source :picnic-near-data-center}])

(defn- add-indices [xs]
  (map #(assoc %1 :index %2) xs (range)))

(defn node-by-id [nodes id]
  (first (filter #(= (:id %) id) nodes)))

(defn nodes []
  (add-indices nodes-data))

(defn links []
  (add-indices links-data))
