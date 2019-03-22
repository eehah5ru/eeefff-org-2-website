;;; start server
(do
  #_(work-sessions.core/-main 6656)
  (figwheel-sidecar.repl-api/start-figwheel! (figwheel-sidecar.config/fetch-config))
  (figwheel-sidecar.repl-api/cljs-repl))
