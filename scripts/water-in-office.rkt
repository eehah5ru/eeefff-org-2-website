#lang racket

(require "timeline-syntax.rkt")

(provide (all-defined-out))


(define (water-in-office)
  (assemblage water-in-office-assemblage

              (video water-in-office-01-video
                     (video-website-path "water-in-office-01.mp4")
                     (duration (identity)))

              (video water-in-office-02-video
                     (video-website-path "water-in-office-02.mp4")
                     (duration (identity)))

              (text water-in-office-text-01
                    "nest of absence"
                    (duration (max (dur water-in-office-01-video)
                                   (dur water-in-office-02-video))))

              (text water-in-office-text-02
                    "interface cannibalism"
                    (duration (max (dur water-in-office-01-video)
                                   (dur water-in-office-02-video))))))

(mk-timeline test-water-in-office
             (water-in-office))
