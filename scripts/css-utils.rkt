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
(define/contract (element-type an-el)
  (-> hash? symbol?)

  (unless (hash-has-key? an-el 'type)
    (error "there is no 'type key" an-el))

  (case (string->symbol (hash-ref an-el 'type))
    [(showVideo) 'video]
    [(showText) 'text]
    [(assemblage) 'assemblage]
    [(showImage) 'image]
    [(addClass) 'add-class]
    [(removeClass) 'remove-class]
    [else 'unknown]))


(define/contract (scss-body an-el)
  (-> hash? string?)
  (string-append ".erosion." (hash-ref an-el 'label) " {\n"
                 "\n"
                 "}\n\n"))

(define/contract (scss-comment an-el [extra-lines '()])
  (->* (hash?) (list?) string?)

  (let ([commented-extra-lines (map (lambda (x)
                                      (string-append "// " x))
                                    extra-lines)])
    (string-append
     (string-join (flatten (list "//"
                                 "//"
                                 (string-append "// " (symbol->string (element-type an-el)) " "(hash-ref an-el 'label))
                                 commented-extra-lines
                                 "//"
                                 "//"))
                  "\n")
     "\n")))


;;
;; video -> scss
;;
(define/contract (video-element->scss an-el)
  (-> hash? string?)

  (string-append (scss-comment an-el)
                 (scss-body an-el)))

;;
;; text -> scsss
;;
(define/contract (text-element->scss an-el)
  (-> hash? string?)
  (string-append (scss-comment an-el (list (hash-ref an-el 'text)))
                 (scss-body an-el)))

;;
;; image -> scss
;;
(define/contract (image-element->scss an-el)
  (-> hash? string?)

  (string-append (scss-comment an-el (list (hash-ref an-el 'src)))
                 (scss-body an-el)))


;;
;; addClass -> scss
;;
(define/contract (add-class->scss an-el)
  (-> hash? string?)

  (let ([class-to-add (hash-ref an-el 'class)]
        [target-id (hash-ref an-el 'id)])
    (string-append (scss-comment an-el (list (format "~a -> #~a" class-to-add target-id )))
                   "#" target-id ".erosion." class-to-add " {\n"
                   "\n"
                   "}\n\n")))


;;
;; assemblage -> scss
;;
(define/contract (assemblage-element->scss an-el)
  (-> hash? string?)

  (string-join (flatten (list (scss-comment an-el)
                              (map element->scss
                                   (hash-ref an-el 'events))))
               "\n\n"))


(define/contract (element->scss an-el)
  (-> hash? string?)

  ;; TODO: add support for addClass and removeClass
  (case (element-type an-el)
    [(assemblage) (assemblage-element->scss an-el)]
    [(video) (video-element->scss an-el)]
    [(text) (text-element->scss an-el)]
    [(image) (image-element->scss an-el)]
    [(add-class) (add-class->scss an-el)]
    [else (error "cannot convert ersion element to scss" an-el)]))
