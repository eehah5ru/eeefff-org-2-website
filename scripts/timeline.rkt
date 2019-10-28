#lang racket


(require (for-syntax "timeline-syntax.rkt")
         "timeline-syntax.rkt")

(require "assemblage-watchdog.rkt"
         "video-spinner-spi.rkt"
         "assemblage-kot-odin.rkt"
         "screen-is-blinking.rkt"
         "outsourcing-orgy.rkt"
         "water-in-office.rkt"
         "pause.rkt"
         "images.rkt"
         "bare-videos.rkt")


(mk-timeline
 outsoursing-paradise-parasite

 (outsourcing-orgy)
 (general-intellect-care)
 (water-in-office)
 (pause)
 (watchdog)
 (kot-odin)


 (video-spinner-spi)
 (screen-is-blinking)
 (cradle-song-03-blur)
 (dominatrix-volgograd-01)
 (perezagruzka)
 (scroll-rab)
 (sleep-vertical)
 (spinner-dorogoi-posetitel-kluba)
 (spinner-konec)
 (stop-word-vertical)
 (taxi-driver)
 (user-experience-vertical)
 (vremya-prikljucheniy-nastupilo)
 (spinner-krutit-spinner-04)
 (spinner-ya-vhozhu-vo-vkus)
 (interface-dominatrix-01)
 (panic-attack-new-01)
 (panic-attack-new-02)
 (panic-attack-new-04)
 (panic-attack-new-05)

 )


(define (slurp-outsorsing-paradise)
  (slurp-json-outsoursing-paradise-parasite-timeline ".."))

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
