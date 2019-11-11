#lang racket

(require "timeline-syntax.rkt")

(provide (all-defined-out))

(define (general-intellect-care)
  (image general-intellect-care-image
         (image-website-url "general-intellect-care.gif")
         (duration (* 1 13520))
         (position 'absolute)))


(mk-timeline test-general-intellect-care
             (general-intellect-care))

(current-directory "..")
