(ns eeefff-org-website.subtitles
  (:require [cljs.pprint :refer [pprint]]))


;; var trackElements = document.querySelectorAll("track");
;; // for each track element
;; for (var i = 0; i < trackElements.length; i++) {
;;   trackElements[i].addEventListener("load", function() {
;;     var textTrack = this.track; // gotcha: "this" is an HTMLTrackElement, not a TextTrack object
;;     var isSubtitles = textTrack.kind === "subtitles"; // for example...
;;     // for each cue
;;     for (var j = 0; j < textTrack.cues.length; ++j) {
;;       var cue = textTrack.cues[j];
;;       // do something
;;     }
;; }

(defn set-cue-events []
  (pprint "setting cue events")

  (.. (js/jQuery "track")
      (on "cuechange" (fn [event]
                   (this-as this
                     (pprint "cue changed")

                     (let [cue (first (array-seq (.. this
                                                     -track
                                                     -activeCues)))]

                       (pprint (.-text cue))
                       (.. (js/jQuery "h1")
                           (html (.-text cue))))))))

  (.. (js/jQuery "track")
      (load (fn [self]
              (this-as this
                (pprint "track loaded")

                (doseq [cue (array-seq (.-cues (.-track this)))]
                  (pprint "cue found"))

                )))))

(defn setup-subtitles []
  (pprint "setup subtitles")

  (set-cue-events))
