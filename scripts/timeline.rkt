#lang racket

;; (provide main)

(require (for-syntax racket/syntax
                     syntax/parse
                     racket))

(require (for-template racket))
(require syntax/parse)

(require json)
(require racket/hash)

(require "video_utils.rkt")



(define delay 30)
(define force-stop #f)


;; {
;;   "config": {
;;     "delay": 30,
;;     "disabled": false
;;   },

;;   "timeline": [
;;     {
;;       "type": "showText",
;;       "duration": 20000,
;;       "position": "absolute",
;;       "text": "Как поверить в будущее, если оно плохо отрендерено?",
;;       "class": "erosion text-01"
;;     },
;;     {
;;       "type": "showVideo",
;;       "loop": true,
;;       "duration": 24664,
;;       "position": "absolute",
;;       "class": "video-01",
;;       "url_mp4": "https://dev.eeefff.org/data/outsourcing-paradise-parasite/pi-02/01.mov.mp4",
;;       "subtitles_en": "https://dev.eeefff.org/data/outsourcing-paradise-parasite/subtitles_test.vtt",
;;       "class": "erosion video-01"
;;     },
;;     {
;;       "type": "assemblage",
;;       "duration": 40000,
;;       "events": [
;;         {
;;           "type": "showVideo",
;;           "loop": false,
;;           "position": "absolute",
;;           "duration": 14084,
;;           "url_mp4": "https://dev.eeefff.org/data/outsourcing-paradise-parasite/pi-02/02.mp4.mp4",
;;           "subtitles_en": "https://dev.eeefff.org/data/outsourcing-paradise-parasite/subtitles_test.vtt",
;;           "class": "erosion video-02"
;;         },
;;         {
;;           "type": "showText",
;;           "duration": 10000,
;;           "position": "erosion",
;;           "text": "Утопия с применением плагинов к браузеру и ворованного диджейского софта",
;;           "class": "erosion text-02"
;;         }
;;       ]
;;     }
;;   ]
;; }

;;;
;;;
;;; EXAMPLE
;;;
;;;

;;     {
;;       "type": "showVideo",
;;       "loop": true,
;;       "duration": 24664,
;;       "position": "absolute",
;;       "class": "video-01",
;;       "url_mp4": "https://dev.eeefff.org/data/outsourcing-paradise-parasite/pi-02/01.mov.mp4",
;;       "subtitles_en": "https://dev.eeefff.org/data/outsourcing-paradise-parasite/subtitles_test.vtt",
;;       "class": "erosion video-01"
;;     },


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
  11)

;;; FIXME: implement
(define (mk-video-url kind path)
  "this-is-video-url")


;;; FIXME: implement!
(define (mk-subtitles-url lang path)
  "this-is-subtitle-url")

;;;
;;;
;;; attrs
;;;
;;;
(define css-class
  (curry attr->hasheq 'class))

(define position
  (curry attr->hasheq 'position))


;;;
;;;
;;; syntax utils
;;;
;;;
;; (define-for-syntax (blah-blah k v)
;;   `(hasheq ,k (normalize-attr ,v)))

;; ;;;
;; ;;;
;; ;;; general syntax
;; ;;;
;; ;;; css-class syntax
;; (define-syntax (css-class stx)
;;   (syntax-parse
;;    stx
;;    [(_ a-class:expr)
;;     (let ([bbb (blah-blah 'class #'a-class)])
;;         #bbb)]))


;; ;;; position syntax
;; (define-syntax (position stx)
;;   (syntax-parse
;;    stx
;;    [(_ a-position)
;;     #'(hasheq 'position (normalize-attr a-position))]))


;;; video syntax
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
                'url_webm (mk-video-url 'webm vp)
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


(define-syntax (assemblage stx)
  (define-syntax-class assemblage-label
    #:attributes (sym)
    (pattern al:id
             #:attr sym #''al))

  (syntax-parse
   stx
   [(_ al:assemblage-label evs:expr ...+)
    #'(hasheq 'type "assemblage"
              'label (normalize-attr al.sym)
              'events (list evs ...))]))

;;;
;;;
;;; tests
;;;
;;;

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

(define (filter-by-index f xs)
  (for/list ([x xs]
             [i (range (length xs))]
             #:when (f i))
    x))


(define even-elements
  (curry filter-by-index even?))

(define odd-elements
  (curry filter-by-index odd?))


(let ([xs '(a b c d e)])
  `(,(even-elements xs)
    ,(odd-elements xs)))
