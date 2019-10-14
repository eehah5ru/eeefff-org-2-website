#lang racket

(require racket/path)
(require 2htdp/batch-io)

(define dummy-sybtitles-path "data/outsourcing-paradise-parasite/subtitles_test.vtt")

;;; only mp4 allowed
(define (video-file? path)
  (let ([ext (path-get-extension path)])
    (cond
      [(bytes? ext)
       (equal? ".mp4"
               (bytes->string/utf-8 ext))]

      [else false])))


(define (subtitels-path lang video-path)
  (string-append (path->string video-path) "_" (symbol->string lang) ".vtt"))

;;; FIXME implement
(define (video-has-subtitels? lang path)
  (file-exists? (subtitels-path lang path)))


(define (dummy-subtitels->string)
  (unless (file-exists? dummy-sybtitles-path)
    (error "dummy subtitles don't exist: " dummy-sybtitles-path))

  (file->string dummy-sybtitles-path))


(define (make-dummy-subtitels dummy-subtitels-content lang video-path)
  (let ([s-path (subtitels-path lang video-path)])

    (when (file-exists? s-path)
      (error "overwriting existing subtitels file: " s-path))
   (write-file s-path
               dummy-subtitels-content)))


(define (find-videos-with-missing-subtitels)
  (for*/list ([lang (list 'ru 'en)]
            [p (filter (compose not (curry video-has-subtitels? lang)) (filter video-file? (sequence->list (in-directory))))])
    (list lang p)))


(define (dummy-missing-subtitels path-to-root base-path)
  (parameterize ([current-directory path-to-root])
    (let ([dummy-subtitels-content (dummy-subtitels->string)])
      (parameterize ([current-directory base-path])
        (map (lambda (x)
               (apply (curry make-dummy-subtitels dummy-subtitels-content) x))
             (find-videos-with-missing-subtitels))))))
