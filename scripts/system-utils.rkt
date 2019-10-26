#lang racket

(provide (all-defined-out))

(define (string->clipboard str)
  (with-input-from-string str
    (lambda ()
      (system "LC_ALL=ru_RU.UTF-8 pbcopy"))))
