#lang racket

;;; here are some details about complex macroses:
;;; https://stackoverflow.com/questions/41139868/dynamically-binding-free-identifiers-in-a-function-body

;; (provide main)

(require (for-syntax racket/syntax
                     syntax/parse/define
                     syntax/parse
                     racket))

(require (for-template racket))
(require syntax/parse/define)
(require syntax/parse)
(require racket/stxparam)
(require lathe-comforts)
(require lathe-comforts/hash)

(require json)
(require racket/hash)
(require racket/path)


(require "video_utils.rkt")
(require "css-utils.rkt")
(require "system-utils.rkt")

(provide (all-defined-out)
         (all-from-out "css-utils.rkt")
         (all-from-out "system-utils.rkt"))
;;
;;
;; parameters
;;
;;

;; erosion delay
(define settings-delay (make-parameter "EROSION_DELAY"))

(define settings-disabled (make-parameter false))

(define assets-basedir (make-parameter "data/outsourcing-paradise-parasite/"))

;; (define videos-website-basedir (make-parameter "data/outsourcing-paradise-parasite/videos/"))

(define settings-base-url
  "HOST_NAME/")


;;;
;;;
;;; JSON UTILS
;;;
;;;
(define (timeline->json->clipboard tml)
  (with-input-from-string (jsexpr->string tml)
    (lambda ()
      (parameterize ([current-locale "ru_RU.UTF-8"])
        (system "LC_ALL=ru_RU.UTF-8 pbcopy")))))

;;;
;;;
;;; GENERAL UTILS
;;;
;;;
(define (normalize-attr attr)
  (if (symbol? attr)
      (symbol->string attr)
      attr))

(define (attr->hasheq k v)
  (hasheq k (normalize-attr v)))


;;;
;;;
;;; path utils
;;;
;;;

(define (videos-website-basedir)
  (string-append (assets-basedir)
                 "videos/"))

(define (images-website-basedir)
  (string-append (assets-basedir)
                 "images/"))


(define (video-website-path path)
  (string-append (videos-website-basedir)
                 path))

;;
;; image filename -> url
;; IMPORTANT! includes basedir
;;
(define (image-website-url filename)
  (let ([image-local-path (string-append (images-website-basedir)
                                         filename)])
    (unless (file-exists? image-local-path)
      (error "file does not exist: " image-local-path))

    (string-append settings-base-url
                   image-local-path)))

;;;
;;;
;;; video utils
;;;
;;;


(define (video-duration path)
  (get-video-duration path))

;;
;; make video url for path
;;
(define (mk-video-url kind path)
  (cond
   ;; MP4 URL
   [(eq? kind 'mp4)
    (string-append settings-base-url path)]
   ;; WEBM URL
   [(eq? kind 'webm)
    (error "webm url is unimplemented")]
   ;; UNKNOWN
   [else
    (error (string-append "unknown video type: " (symbol->string kind)))])
  )


;;
;;
;; SUBTITLES UTILS
;;
;;

;;;
;;; check subtitles file exists
;;; returns true or false
;;;
(define (subtitels-exists? path)
  (file-exists? path))

;;; nothing or raise error
(define (check-subtitels-exists? path)
  (unless (subtitels-exists? path)
    (error "cannot find subtitles file: " path)))


;;; return url of raise error
(define (mk-subtitles-url lang path)
  (unless (member lang (list 'ru 'en))
    (error "unknown lang:" lang))

  (let* ([subtitels-path (string-append path "_" (symbol->string lang) ".vtt")]
        [subtitels-url (string-append settings-base-url subtitels-path)])

    (check-subtitels-exists? subtitels-path)

    subtitels-url))


;;;
;;;
;;; timeline elements' attrs
;;;
;;;

(define css-id
  (curry attr->hasheq 'id))

;;;
;;; CSS class
;;;
(define (css-class a-classes)
  (let ([css-classes (cond
                       [(list? a-classes)
                        (string-join (map symbol->string
                                          a-classes))]

                       [else (symbol->string a-classes)])])
    ((compose1 (curry attr->hasheq 'class)
               (curry string-append "erosion "))
     css-classes)))

(define position
  (curry attr->hasheq 'position))

(define looped
  (curry attr->hasheq 'loop))

(define overlay
  (curry attr->hasheq 'overlay))

(define z-index
  (curry attr->hasheq 'z-index))

(define delayed-impl
  (curry attr->hasheq 'delayed))

(define src
  (curry attr->hasheq 'src))


;;;
;;;
;;; DURATION UTILS
;;;
;;;
(define durations (make-hash))

(define (duration-get p)
  (hash-ref durations
            p))

(define (duration-set p d)
  (hash-set! durations
             p
             d))

(define (duration-has? p)
  (hash-has-key? durations p))


(define-syntax (dur stx)
  (syntax-parse stx
    [(_ p:id)
     #'(duration-get 'p)]))


;;
;;
;; TIMELINE UTILS
;;
;;

;;
;; force all delayed exprs
;;
(define (force-timeline t)
  (cond
    [(promise? t)
     (begin
      (force t))]

    [(hash? t)
     (begin
       (hash-v-map t force-timeline))]
    [(list? t)
     (map force-timeline t)]

    [else t]))

;;
;;
;; SYNTAXES
;;
;;

;;
;; label class
;;
(begin-for-syntax
 ;;; event label
 (define-syntax-class event-label
   #:attributes (sym)
   (pattern el:id
            #:attr sym #''el)))

;;
;; define delayed attr syntax
;;
(define-syntax (delayed stx)
  (syntax-parse stx
    [(_ durexpr:expr)
     #'(delayed-impl (delay durexpr))]))

;;;
;;; video syntax
;;;
(define-syntax (video stx)
  (define-syntax-class video-label
    #:attributes (sym)
    (pattern vl:id
             #:attr sym #''vl))

  (define-syntax-class video-path
    (pattern vp:expr))

  (syntax-parse
   stx
   #:datum-literals (duration)
   [(_ vl:video-label vp:video-path attrs1:expr ... (duration (durexpr ...+)) attrs2:expr ...)
    #:with syntax-local-introduce #'duration-set-func
    (displayln (syntax->datum #'vl))
    #`(begin
       (displayln 'runtime-video)
       (duration-set 'vl (video-duration vp))
       (hash-union
        ;;
        (hash-union
         (hasheq 'type "showVideo"
                 'label (normalize-attr vl.sym)
                 'url_mp4 (mk-video-url 'mp4 vp)
                 ;; 'url_webm (mk-video-url 'webm vp)
                 'subtitles_en (mk-subtitles-url 'en vp)
                 'subtitles_ru (mk-subtitles-url 'ru vp)
                 'duration ((curry durexpr ...) (video-duration vp)))
         (css-class (list 'erosion-video 'vl))
         (css-id 'vl)
         attrs1 ...
         attrs2 ... )))]))


;;;
;;; text syntax
;;;
(define-syntax (text stx)
  (define-syntax-class text-label
    #:attributes (sym)
    (pattern tl:id
             #:attr sym #''tl))

  (syntax-parse
   stx
   #:datum-literals (duration)
   [(_ tl:text-label t:string attrs1:expr ... (duration durexpr:expr) attrs2:expr ...)
    #'(hash-union
       (hasheq 'type "showText"
               'label (normalize-attr tl.sym)
               'text t
               'duration (delay durexpr))
       (css-class (list 'erosion-text 'tl))
       (css-id 'tl)
       attrs1 ...
       attrs2 ...)]))


;;
;; image syntax
;;
(define-syntax (image stx)
  (syntax-parse stx
    #:datum-literals (duration)
    [(_ il:event-label s:expr attrs1:expr ... (duration durexpr:expr) attrs2:expr ...)
     #'(hash-union
        (hasheq 'type "showImage"
                'label (normalize-attr il.sym)
                'src s
                'duration (delay durexpr))
        (css-class (list 'erosion-image 'il))
        (css-id 'il)
        attrs1 ...
        attrs2 ...)]))

;;;
;;; addClass syntax
;;;
;;; this event can be delayed but duration is not applicable
;;;
(define-syntax (add-class stx)
  (syntax-parse stx
    [(_ acl:event-label class-to-add:expr target-id:expr attrs:expr ...)
     #'(hash-union
        (hasheq 'type "addClass"
                'label (normalize-attr 'acl)
                'class (normalize-attr class-to-add)
                'id (normalize-attr target-id))
        attrs ...)]))

;;;
;;; removeClass syntax
;;;
;;; can be delayed but without duration
;;;
(define-syntax (remove-class stx)
  (syntax-parse stx
    [(_ rcl:event-label class-to-remove:expr target-id:expr attrs:expr ...)
     #'(hash-union
        (hasheq 'type "removeClass"
                'label (normalize-attr 'rcl)
                'class (normalize-attr class-to-remove)
                'id (normalize-attr target-id))
        attrs ...)]))

;;;
;;; assemblage syntax
;;;
(define-syntax (assemblage stx)
  (define-syntax-class assemblage-label
    #:attributes (sym)
    (pattern al:id
             #:attr sym #''al))

  (syntax-parse
   stx
   [(_ al:assemblage-label  evs1:expr ... evs2:expr ...)
    #'(hasheq 'type "assemblage"
              'label (normalize-attr al.sym)
              'events (list evs1 ...
                            evs2 ...))]))

;;;
;;; timline syntax
;;;
(define-syntax (timeline stx)
  (syntax-parse
   stx
   [(_ el:event-label tls:expr ...+)
    (displayln (syntax->datum #'el))
    #'(force-timeline
       (begin
         (displayln 'runtime-timeline)
         (pretty-print durations)
         (hasheq 'config (hasheq 'disabled  (settings-disabled)
                                 'delay (settings-delay))
                 'timeline (list tls ...))))]))


;;;
;;; mk-timeline syntax
;;; defines the whole function to generate it
;;;
(define-syntax (mk-timeline stx)
  (syntax-parse
   stx
   [(_ tml-name:event-label tls:expr ...+)
    (let ([timeline-func-name (format-id #'tml-name "mk-~a-timeline" #'tml-name)]
          [slurp-json-func-name (format-id #'tml-name "slurp-json-~a-timeline" #'tml-name)])
      #`(begin
          (define (#,timeline-func-name base-dir)
           (parameterize ([current-directory base-dir])
             (timeline
              tml-name
              tls ...)))

          (define (#,slurp-json-func-name base-dir)
            (timeline->json->clipboard (#,timeline-func-name base-dir)))))]))

;;;
;;;
;;; HELPERS
;;;
;;;

;;;
;;; simple video
;;;
(define-syntax (bootstrap-video stx)
  (syntax-parse
      stx
    [(_ vl:event-label vp:string)
     (let ([test-timeline-name (format-id #'vl "test-~a" #'vl)]
           [video-element-name (format-id #'vl "~a-video" #'vl)])
       #`(begin
           (define (vl)
             (video #,video-element-name
                    (video-website-path vp)
                    (duration (identity))
                    (looped false)
                    (position 'absolute)))

           (mk-timeline #,test-timeline-name
                        (vl))

           (current-directory "..")))]))
