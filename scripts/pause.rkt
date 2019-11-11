#lang racket

(require "timeline-syntax.rkt")

(provide (all-defined-out))

(define (pause)
  (assemblage pause-assemblage

              (video pause-video
                     (video-website-path "pause.mp4")
                     (duration (identity)))

              (text pause-text
                    "4-MINUTES PAUSE"
                    (duration (dur pause-video)))))

(mk-timeline test-pause
             (pause))
