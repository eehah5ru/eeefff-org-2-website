(defproject eeefff_org_website "0.1.0-SNAPSHOT"
  :description "eeefff's website"
  :url "https://eeefff.org"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  :dependencies [[org.clojure/clojure "1.10.0"]
                 ;;
                 ;; clojurescript
                 ;;
                 [org.clojure/clojurescript "1.10.520"]
                 [cljsjs/d3 "5.9.1-0"]
                 [binaryage/oops "0.7.0"]

                 [enfocus "2.1.1"]

                 [reagent "0.8.0-alpha2"]
                 [reagent-utils "0.3.1"]
                 [re-frame "0.10.5"]
                 [jayq "2.5.4"]]

  :plugins [[lein-cljsbuild "1.1.7"]
            [org.clojars.eehah5ru/cljsbuild-extras "0.0.2"]]

  ; :main ^:skip-aot eeefff-org-website.core
  :target-path "target/%s"

  :repl-options {:nrepl-middleware [cider.piggieback/wrap-cljs-repl]}

  :profiles
  {
   ;;
   ;; local dev
   ;;
   :dev
   {:dependencies [[binaryage/devtools "0.8.2"]
                                        ;[com.cemerick/piggieback "0.2.1"]
                   [cider/piggieback "0.4.0"]
                   [figwheel-sidecar "0.5.18"]
                   [org.clojure/tools.nrepl "0.2.13"]]

    :plugins [[lein-figwheel "0.5.18"]]

    :source-paths ["src_cljs" "env/dev"]
    ;;
    ;; generate index.html
    ;;
    ;; :filegen-ng [{:data {:template ~(slurp "resources/public/index_tpl.html")
    ;;                      :version ~(fn [p] (:version p))}
    ;;               :template-fn ~(fn [p d] (:template d))
    ;;               :target "resources/public/index.html"}]

    ;;
    ;; build cljs
    ;;
    :cljsbuild {:builds [{:id "dev"
                          :source-paths ["src_cljs"]
                          :figwheel {:on-jsload "eeefff-org-website.core/mount-root"}
                          :compiler {:main ^:skip-aot eeefff-org-website.core
                                     :output-to "resources/public/js/compiled/out/main.js"
                                     :output-dir "resources/public/js/compiled/out"
                                     :asset-path "/js/compiled/out"
                                     :source-map-timestamp true
                                     :optimizations :none
                                     :closure-defines {goog.DEBUG true}
                                     :preloads [print.foo.preloads.devtools]}}]}

    }
   :uberjar {:aot :all}})
