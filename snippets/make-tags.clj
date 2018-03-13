(require '[clojure.string :as s :refer [split capitalize]])
(require '[clojure.pprint :refer [pprint]])
;; (require          '[clojure.core.match.regex])

(def raw-tags "algorithmic solidarity, communality of alienation, emotional computing, digital colonialism, platform perplex, digital materiality, emotional computing, radical hybridity, digital colonialism, imagined-but-as-yet-not-real, critical interfaces, algorithmic solidarity, emotional computing, transactional solidarity, digital colonialism, imagined-but-as-yet-not-real, critical interfaces, digital colonialism, real-but-as-yet-unnamed, emotional computing, critical interfaces, algorithmic solidarity, culture synthesizers, paradise politics, weareuntrained, digital materiality, platform perplex, who owns resources?, digital materiality, platform perplex, who owns resources?, emotional computing, critical interfaces, weareuntrained, who owns resources?, emotional computing, platform perplex, critical interfaces, culture synthesizers, weareuntrained, culture synthesizers, weareuntrained, platform perplex, critical interfaces, emotional computing, digital materiality, critical interfaces, nervous ai, machinic agency, algorithmic solidarity, emotional computing, critical interfaces, machinic agency, imagined-but-as-yet-not-real, fuck discourse let's dance, communality of alienation, data flows, digital materiality, platform perplex, who owns resources?, digital colonialism, weareuntrained, emotional computing, digital materiality, platform perplex, who owns resources?, digital colonialism, emotional computing, platform perplex, who owns resources?, weareuntrained, digital colonialism")

(def raw-projects
  [
   {:name "cloud-bushes"
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

(defn mk-name [n]
  (->> (split n #" ")
      (map s/capitalize)
      ;; (interpose " ")
      (s/join " ")))

(defn mk-tags [tags-string]
  (let [tag-names (-> tags-string
                      (split #", ")
                      sort
                      distinct)]
    (pprint (map #(hash-map :id (s/replace % #" " "-")
                     :name (mk-name %))
          tag-names))))
