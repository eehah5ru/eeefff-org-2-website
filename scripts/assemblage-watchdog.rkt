#lang racket

(require "timeline-syntax.rkt")

(provide (all-defined-out))

(define assemblage-watchdog
  (parameterize ([current-directory ".."])
   (assemblage watchdog
               (duration (* 2 (dur watchdog-video)))

               (video watchdog-video
                      "data/outsourcing-paradise-parasite/videos/spinner-watchdog-session.mp4"
                      (duration (* 2))
                      (looped true)
                      (position 'absolute))

               (text watchdog-text-01
                     "Во время сессии порой будут наступать ватчдог-паузы - моменты, когда тебе нужно будет принять заранее отрепетированную позу. Позу, которая позволит алгоритмам убедиться, что ты не скрипт и не бот, а живой человек."
                     (duration (/ (dur watchdog-video) 2))
                     (position 'absolute))

               (text watchdog-text-02
                     "Ватчдог-паузы будут наступать, когда текст этого документа будет чернеть."
                     (duration (/ (dur watchdog-video) 2))
                     (delayed (/ (dur watchdog-video) 2)))

               (text watchdog-text-03
                     "Теперь выбери позу. Она должна быть нечеловеческой, но не отсылать к роботам и прочим трансформерам (сама реши, как это)"
                     (duration (/ (dur watchdog-video) 2))
                     (delayed (dur watchdog-video)))

               (text watchdog-text-04
                     "Давай порепетируем."
                     (duration (/ (dur watchdog-video) 2))
                     (delayed (* 1.5 (dur watchdog-video)))))))

(mk-timeline test-timeline-assemblage-watchdog
             assemblage-watchdog)
