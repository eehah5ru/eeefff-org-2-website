(ns user
  (:use [figwheel-sidecar.repl-api :as ra]
            ))

(set! *warn-on-reflection* true)
(set! *unchecked-math* :warn-on-boxed)

#_(def http-handler
    (wrap-reload #'work-sessions.core/http-handler))

(defn start [] (ra/start-figwheel!))

(defn stop [] (ra/stop-figwheel!))

(defn cljs [] (ra/cljs-repl "dev"))
