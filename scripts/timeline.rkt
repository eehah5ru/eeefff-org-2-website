#lang racket


(require (for-syntax "timeline-syntax.rkt")
         "timeline-syntax.rkt")

(require "assemblage-watchdog.rkt"
         "video-spinner-spi.rkt")


(mk-timeline
 test-minimal

 video-spinner-spi
 assemblage-watchdog)

;;;
;;;
;;; TIMELINES
;;;
;;;



;; (mk-timeline
;;  no-name-outsourcers
;;  ;;
;;  ;; beginning text
;;  ;;
;;  (text no-name-outsourcers-01
;;        "no-name outsourcers will be here in a short time"
;;        (duration 6000)
;;        (position 'erosion
;;                  ))

;;  (text outsourcing-orgy
;;        "Outsourcing Orgy"
;;        (duration 2000)
;;        (position 'erosion))

;;  (assemblage
;;   no-name-outsourcers-02
;;   (duration (* 2 (dur spinner-video)))

;;   (text no-name-outsourcers-02-text
;;        "do not move and wait for them"
;;        (duration (dur spinner-video))
;;        (delayed (dur spinner-video))
;;        (position 'absolute))

;;   (video spinner-video
;;            "data/outsourcing-paradise-parasite/selected-04/blur-08.mp4"
;;            (duration (* 2))
;;            (looped true)
;;            (position 'absolute)))

;;  )


;; ;;;
;; ;;; test all-in-one timeline
;; ;;;
;; (mk-timeline
;;  all-in-one

;;  ;; just text
;;  (text no-name-outsourcers-01
;;        "no-name outsourcers will be here in a short time"
;;        (duration 2000)
;;        (position 'absolute
;;                  ))

;;  ;; just image
;;  (image participants-pic
;;        "https://eeefff.org/images/error-friendly-networks/participants.jpg"
;;        (duration 2000)
;;        (position 'absolute
;;                  ))

;;  ;; gif falling diagram
;;  (image falling-diagram
;;        "https://eeefff.org/images/error-friendly-networks/out-640.gif"
;;        (duration 2000)
;;        (position 'absolute
;;                  ))

;;  ;; assemblage
;;  ;; with delayed element and adding/removing classes
;;  (assemblage
;;   no-name-outsourcers-02
;;   (duration (* 4 (dur spinner-video)))

;;   (text no-name-outsourcers-02-text
;;        "do not move and wait for them"
;;        (duration (* 2 (dur spinner-video)))
;;        (delayed (dur spinner-video))
;;        (position 'absolute))

;;   (video spinner-video
;;            "data/outsourcing-paradise-parasite/selected-04/bots.mp4"
;;            (duration (* 4))
;;            (looped true)
;;            (position 'absolute))

;;   (add-class some-class-to-video
;;              'some-class
;;              'spinner-video
;;              (delayed (dur spinner-video)))

;;   (remove-class some-class-from-video
;;                 'some-video
;;                 'spinner-video
;;                 (delayed (* 2 (dur spinner-video))))

;;   (add-class another-class-to-text
;;              'another-class
;;              'no-name-outsourcers-02-text
;;              (delayed (+ 1000 (dur spinner-video))))

;;   (remove-class another-class-from-text
;;                 'another-class
;;                 'no-name-outsourcers-02-text
;;                 (delayed (+ 4000 (dur spinner-video)))))

;;  )
