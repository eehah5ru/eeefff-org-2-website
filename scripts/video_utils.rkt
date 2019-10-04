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
;;; FIXME: not longer than a minute!
(define duration/p
  (do
    (string/p "Duration")
    (many+/p space/p)
    (string/p ":")
    (many+/p space/p)
    [secs <- integer/p]
    (string/p " s ")
    [millis <- integer/p]
    (string/p " ms")
    (pure (list secs millis))))

;;;
;;; get video duration
;;;
(define (get-video-duration video-path)
  (check-video-eixists video-path)

  (let* ([mediainfo-cmd (string-join (list "mediainfo"
                                        video-path
                                        "| grep Duration"
                                        "| head -1"))]
         [raw-data (with-output-to-string (lambda () (system mediainfo-cmd)))]
         [dur-list (parse-result! (parse-string duration/p raw-data))])
    ;;
    ;; FIXME: not longer than a minute
    ;;
    (+ (last dur-list)
       (* 1000 (first dur-list)))))


;;;
;;; main
;;;
(define (main video-path)
  (displayln (get-video-duration video-path)))
