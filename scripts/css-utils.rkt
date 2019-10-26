#lang racket

(require racket/contract)
(require racket/hash)
(require "system-utils.rkt")

(provide (all-defined-out)
         (all-from-out "system-utils.rkt"))

;;
;;
;; UTILS FOR GENERATING SCSS SKELETON FROM TIMLENE STRUCTURES
;;
;;


;;;
;;; type to symbol
;;;
(define/contract (erosion-element-type an-el)
  (-> hash? symbol?)

  (unless (hash-has-key? an-el 'type)
    (error "there is no 'type key" an-el))

  (let ([rawType (hash-ref an-el 'type)])
    (cond
     ((eq? rawType "showVideo")
      'video)

     ((eq? rawType "showText")
      'text)

     (true 'other))))


(define/contract (element->scss an-el)
  (-> hash? string?)

  (string-append "\n//\n// " (symbol->string (erosion-element-type an-el)) " "(hash-ref an-el 'label) "\n//\n"
                 ".erosion." (hash-ref an-el 'label) " {\n"
                 "\n"
                 "}\n\n"))

;; (define/contract (video->scss an-el)
;;   (-> hash? string?)
;;   (element->scss 'video ))


;; (define/contract (text->scss an-el)
;;   (-> hash? string?)

;;   (string-append "//\n// text" ))

;;;
;;; generate scss code
;;;
(define/contract (erosion-assemblage->scss-code an-assemblage)
  (-> hash? string?)

  (apply string-append (map element->scss
                            (hash-ref an-assemblage 'events))))
