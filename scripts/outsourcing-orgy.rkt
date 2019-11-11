#lang racket

(require "timeline-syntax.rkt")

(provide (all-defined-out))

(define (outsourcing-orgy)
  (assemblage outsourcing-orgy-assemblage

              (image outsourcing-orgy-image
                     (image-website-url "outsourcing-orgy.svg")
                     (duration 6000))

              (add-class
               outsourcing-orgy-image-growing
               'outsourcing-orgy-image-growing
               'outsourcing-orgy-image
               (delayed 2000))))

(mk-timeline test-outsourcing-orgy
             (outsourcing-orgy))

(current-directory "..")
