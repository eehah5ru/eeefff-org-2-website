#lang racket

(require data/monad)
(require megaparsack megaparsack/text)
(require data/functor)
(require data/applicative)

(provide get-video-duration)


(define (check-video-eixists video-path)
  (cond
   [(not (file-exists? video-path))
    (raise-user-error (string-append "video file does not exist "
                                     video-path))]))

;;;
;;; parser for video duration
;;;
(define duration/p

  (do
    (string/p "Duration")
    (many+/p space/p)
    (string/p ":")
    (many+/p space/p)
    [hours <- integer/p]
    (string/p ":")
    [mins <- integer/p]
    (string/p ":")
    [secs <- integer/p]
    (string/p ".")
    [millis <- integer/p]

    (pure (list hours mins secs millis))))

;;;
;;; get video duration
;;;
(define (get-video-duration video-path)
  (check-video-eixists video-path)

  (let* ([mediainfo-cmd (string-join (list "mediainfo"
                                           "-f"
                                        video-path
                                        "| grep Duration"
                                        "| grep '[0-9][0-9]:[0-9][0-9]:[0-9][0-9]\\.'"
                                        "| head -1"))]
         [raw-data (with-output-to-string (lambda () (system mediainfo-cmd)))])

    (match-let ([(list hours mins secs millis) (parse-result! (parse-string duration/p raw-data))])
      (+ millis
         (* 1000
            (+ secs
               (* 60 mins)
               (* 3600 hours)))))))


;;;
;;; main
;;;
(define (main video-path)
  (displayln (get-video-duration video-path)))
