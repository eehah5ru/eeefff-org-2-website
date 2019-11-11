#lang racket

(require "timeline-syntax.rkt")

(provide (all-defined-out))

(define (watchdog)
  (assemblage watchdog-assemblage

              (video watchdog-video
                     "data/outsourcing-paradise-parasite/videos/spinner-watchdog-session.mp4"
                     (duration (identity))
                     (looped false)
                     (position 'absolute))

              (text watchdog-text-01
                    "Watchdog position"
                    (duration (dur watchdog-video))
                    (position 'absolute))

              (text watchdog-text-02
                    "allows algorithms to make sure that you are neither a script nor a bot, but a human"
                    (duration (dur watchdog-video)))))

(mk-timeline test-timeline-assemblage-watchdog
             (watchdog))
