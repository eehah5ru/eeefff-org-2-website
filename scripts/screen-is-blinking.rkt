#lang racket

(require "timeline-syntax.rkt")

(provide (all-defined-out))


(bootstrap-video screen-is-blinking
                 "cradle-song-02-screen.mp4")


;; (define (screen-is-blinking)
;;   (video screen-is-blinking-video
;;          (video-website-path "cradle-song-02-screen.mp4")
;;          (duration (identity))
;;          (looped false)
;;          (position 'absolute)))

;; (mk-timeline test-screen-is-blinking
;;              (screen-is-blinking))

;; (current-directory "..")
