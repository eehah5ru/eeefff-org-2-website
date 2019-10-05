#lang racket

;; (provide main)

(require (for-syntax racket/syntax
                     syntax/parse
                     racket))

(require (for-template racket))
(require syntax/parse)

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


;;; FIXME: implement!
(define (mk-subtitles-url lang path)
  (unless (member lang (list 'ru 'en))
    (error "unknown lang:" lang))

  (string-append settings-video-base-url path "_" (symbol->string lang) ".vtt"))

;;;
;;;
;;; attrs
;;;
;;;

(define css-id
  (curry attr->hasheq 'id))

(define (css-class a-class)
  ((compose1 (curry attr->hasheq 'class)
             (curry string-append "erosion ")
             symbol->string)
   a-class))

(define position
  (curry attr->hasheq 'position))

(define looped
  (curry attr->hasheq 'loop))

(define overlay
  (curry attr->hasheq 'overlay))

(define z-index
  (curry attr->hasheq 'z-index))

(define delayed
  (curry attr->hasheq 'delayed))


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
    #'(hash-union
       ;;
       (hash-union
        (hasheq 'type "showVideo"
                'label (normalize-attr vl.sym)
                'url_mp4 (mk-video-url 'mp4 vp)
                ;; 'url_webm (mk-video-url 'webm vp)
                'subtitles_en (mk-subtitles-url 'en vp)
                'subtitles_ru (mk-subtitles-url 'ru vp)
                'duration ((curry durexpr ...) (video-duration vp)))
        attrs1 ...
        attrs2 ... ))]))

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
               'duration durexpr)
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
              'duration durexpr
              'events (list evs1 ...
                            evs2 ...))]))

;;;
;;; timline syntax
;;;
(define-syntax (timeline stx)
  (syntax-parse
   stx
   [(_ el:event-label tls:expr ...+)
    #'(hasheq 'config (hasheq 'disabled settings-disabled
                              'delay settings-delay)
              'timeline (list tls ...))]))


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
(define (test-timeline)
  (let ([data (delay (timeline this-is-timeline
                    ;; first video
                    (video some-video
                           "path-to-video-file"
                           (duration (const 3))
                           (css-class 'video-class-01)
                           (position 'absolute))

                    (text some-text
                          "this is some text to show on the website"
                          (duration 3333)
                          (css-class 'text-class-01)
                          (position 'fixed))))])
    (force data)))

;;; test video syntax
(define (test-video)
  (video some-video
         "path-to-video-file"
         (duration (const 3))
         (css-class 'video-class-01)
         (position 'absolute)))

;;; test text syntax
(define (test-text)
  (text some-text
        "this is some text to show on the website"
        (duration 3333)
        (css-class 'text-class-01)
        (position 'fixed)))


;;; test assemblage
(define (test-assemblage)
  (assemblage some-assemblage
              (duration 1000)
              (video some-other-video
                     "path-to-video-2"
                     (duration (+ 100000)))
              (video totally-different-video
                     "path-to-video-3"
                     (duration (identity)))

              (text text-2
                    "this is text number 2"
                    (duration 1000))))

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
(mk-timeline
  simple-test-2
  ;; first video
  (let ([factor 0.1])
    (video some-video
           "data/outsourcing-paradise-parasite/pi-02/02.mp4.mp4"
           (duration (* 2 factor))
           (looped true)
           (css-class 'video-class-01)
           (position 'absolute)))

  (text some-text
        "this is some text to show on the website"
        (duration 3333)
        (css-class 'text-class-01)
        (position 'absolute)))




(mk-timeline
 no-name-outsourcers
 (text no-name-outsourcers-01
       "no-name outsourcers will be here in a short time"
       (duration 6000)
       (position 'absolute)
       (css-class 'no-name-outsourcers-01))

 (assemblage
  no-name-outsourcers-02
  (duration 10000)

  (text no-name-outsourcers-02-text
       "do not move and wait for them"
       (duration 6000)
       (delayed 3000)
       (position 'absolute)
       (css-class 'no-name-outsourcers-02))

  (video no-name-outsourcers-02-video
           "data/outsourcing-paradise-parasite/pi-02/02.mp4.mp4.mp4"
           (duration (* 2))
           (looped true)
           (css-class 'no-name-outsourcers-02-video)
           (position 'absolute)))
 )
