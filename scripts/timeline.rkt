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



(define settings-delay 5)
(define settings-disabled #f)

(define settings-video-base-url
  "HOST_NAME/")

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
;;; video utils
;;;
;;;

;;; FIXME: replace with actual function
(define (video-duration path)
  (get-video-duration path))


;;; FIXME: implement
(define (mk-video-url kind path)
  (cond
   ;; MP4 URL
   [(eq? kind 'mp4)
    (string-append settings-video-base-url path)]
   ;; WEBM URL
   [(eq? kind 'webm)
    (error "webm url is unimplemented")]
   ;; UNKNOWN
   [else
    (error (string-append "unknown video type: " (symbol->string kind)))])
  )

;;;
;;; subtitles utils
;;;

;;; true or false
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
        [subtitels-url (string-append settings-video-base-url subtitels-path)])

    (check-subtitels-exists? subtitels-path)

    subtitels-url))


;;;
;;;
;;; attrs
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


;;;
;;;
;;; paramaterezed duration utils
;;;
;;;
(define-syntax-parameter test-syntax-par #f)

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

;;;
;;;
;;; syntax utils
;;;
;;;
;; (define-for-syntax (blah-blah k v)
;;   `(hasheq ,k (normalize-attr ,v)))

;;;
;;;
;;; general syntax
;;;


(begin-for-syntax
 ;;; event label
 (define-syntax-class event-label
   #:attributes (sym)
   (pattern el:id
            #:attr sym #''el)))


;; (define-syntax (duration-set stx)
;;    (syntax-parse stx
;;      [(duration-set an-id:id v:expr)
;;       #'(duration-set-func 'an-if v)]))


(define-syntax (delayed stx)
  (syntax-parse stx
    [(_ durexpr:expr)
     #'(delayed-impl (delay durexpr))]))


;;;
;;;
;;; video syntax
;;;
;;;
(define-syntax (video stx)
  (define-syntax-class video-label
    #:attributes (sym)
    (pattern vl:id
             #:attr sym #''vl))

  (define-syntax-class video-path
    (pattern vp:string))

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
       attrs1 ...
       attrs2 ...)]))

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
   #:datum-literals (duration)
   [(_ al:assemblage-label  evs1:expr ... (duration durexpr:expr) evs2:expr ...)
    #'(hasheq 'type "assemblage"
              'label (normalize-attr al.sym)
              'duration (delay durexpr)
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
         (syntax-parameterize ([test-syntax-par 'aaa])
          (displayln 'runtime-timeline)
          (pretty-print durations)
          (hasheq 'config (hasheq 'disabled settings-disabled
                                  'delay settings-delay)
                  'timeline (list tls ...)))))]))


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
;;; tests
;;;
;;;

;;; test timeline
;; (define (test-timeline)
;;   (let ([data (delay (timeline this-is-timeline
;;                     ;; first video
;;                     (video some-video
;;                            "path-to-video-file"
;;                            (duration (const 3))
;;                            (css-class 'video-class-01)
;;                            (position 'absolute))

;;                     (text some-text
;;                           "this is some text to show on the website"
;;                           (duration 3333)
;;                           (css-class 'text-class-01)
;;                           (position 'fixed))))])
;;     (force data)))

;; ;;; test video syntax
;; (define (test-video)
;;   (video some-video
;;          "path-to-video-file"
;;          (duration (const 3))
;;          (css-class 'video-class-01)
;;          (position 'absolute)))

;; ;;; test text syntax
;; (define (test-text)
;;   (text some-text
;;         "this is some text to show on the website"
;;         (duration 3333)
;;         (css-class 'text-class-01)
;;         (position 'fixed)))


;; ;;; test assemblage
;; (define (test-assemblage)
;;   (assemblage some-assemblage
;;               (duration 1000)
;;               (video some-other-video
;;                      "path-to-video-2"
;;                      (duration (+ 100000)))
;;               (video totally-different-video
;;                      "path-to-video-3"
;;                      (duration (identity)))

;;               (text text-2
;;                     "this is text number 2"
;;                     (duration 1000))))

;;;
;;;
;;; funciton
;;;
;;;
(define (video-f path loop? duration position css-class)
  (let ([url-mp4 (mk-video-url 'mp4 path)]
        [url-webm (mk-video-url 'webm path)]
        [url-subtitles-ru (mk-subtitles-url 'ru path)]
        [url-subtitles-en (mk-subtitles-url 'en path)]
        [duration (* duration (video-duration path))] ; FIXME: replace with actual duration
        [position (normalize-attr position)]
        [css-class (normalize-attr css-class)])

    (hasheq
     'url_mp4 url-mp4
     'url_webm url-webm
     'subtitles_en url-subtitles-en
     'subtitles_ru url-subtitles-ru
     'type "showVideo"
     'loop loop?
     'duration duration
     'position position
     'class css-class)))

;;;
;;; test video-f
;;;
(define (test-video-f)
  (video-f "a-path"
           true
           9999
           'absolute
           "video-class-01"))

;; (video blah-blah-label
;;        "/blah/blah"
;;        (loop #t)
;;        (duration (* (video-duration) 2))

;;        (position 'absolute)
;;        (class 'video-01))

;; (text blinking-outsourcing-paradise
;;       "outsourcing paradise"
;;       (duration 1000)
;;       (position 'absolute)
;;       (class 'text-02))

;; (assemblage
;;  duration 2000

;;  (video
;;   )

;;  (text
;;   ))

;;;
;;;
;;; experiments
;;;
;;;

;; (define (filter-by-index f xs)
;;   (for/list ([x xs]
;;              [i (range (length xs))]
;;              #:when (f i))
;;     x))


;; (define even-elements
;;   (curry filter-by-index even?))

;; (define odd-elements
;;   (curry filter-by-index odd?))


;; (let ([xs '(a b c d e)])
;;   `(,(even-elements xs)
;;     ,(odd-elements xs)))

;;;
;;; JSON UTILS
;;;
(define (timeline->json->clipboard tml)
  (with-input-from-string (jsexpr->string tml) (lambda () (system "pbcopy"))))

;;;
;;;
;;; TIMELINES
;;;
;;;

;;; simple test
;; (mk-timeline
;;   simple-test-2
;;   ;; first video
;;   (let ([factor 0.1])
;;     (video some-video
;;            "data/outsourcing-paradise-parasite/pi-02/02.mp4.mp4"
;;            (duration (* 2 factor))
;;            (looped true)
;;            (css-class 'video-class-01)
;;            (position 'absolute)))

;;   (text some-text
;;         "this is some text to show on the website"
;;         (duration 3333)
;;         (css-class 'text-class-01)
;;         (position 'absolute)))


(mk-timeline
 no-name-outsourcers
 ;;
 ;; beginning text
 ;;
 (text no-name-outsourcers-01
       "no-name outsourcers will be here in a short time"
       (duration 6000)
       (position 'absolute))

 (text outsourcing-orgy
       "Outsourcing Orgy"
       (duration 20000)
       (position 'erosion))

 (assemblage
  no-name-outsourcers-02
  (duration (* 2 (dur spinner-video)))

  (text no-name-outsourcers-02-text
       "do not move and wait for them"
       (duration (dur spinner-video))
       (delayed (dur spinner-video))
       (position 'absolute))

  (video spinner-video
           "data/outsourcing-paradise-parasite/selected-04/spinner.mp4"
           (duration (* 2))
           (looped true)
           (position 'absolute))))
