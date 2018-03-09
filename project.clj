(defproject eeefff_org_website "0.1.0-SNAPSHOT"
  :description "eeefff's website"
  :url "https://eeefff.org"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}
  :dependencies [[org.clojure/clojure "1.9.0"]
                 ;;
                 ;; clojurescript
                 ;;
                 [org.clojure/clojurescript "1.9.946"]
                 [cljsjs/d3 "4.12.0-0"]]
  :plugins [[lein-cljsbuild "1.1.7"]
            [org.clojars.eehah5ru/cljsbuild-extras "0.0.2"]]
  :main ^:skip-aot eeefff-org-website.core
  :target-path "target/%s"

  :repl-options {:nrepl-middleware [cemerick.piggieback/wrap-cljs-repl]}

  :profiles
  {
   ;;
   ;; local dev
   ;;
   :dev
   {:dependencies [[binaryage/devtools "0.8.2"]
                   [com.cemerick/piggieback "0.2.1"]
                   [figwheel-sidecar "0.5.13"]
                   [org.clojure/tools.nrepl "0.2.11"]]

    :plugins [[lein-figwheel "0.5.13"]]

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
