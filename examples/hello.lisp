#!/usr/bin/env cortado

;; Simple hello world script
(print "Hello, World!")

;; Some calculations
(defn factorial [n]
  (if (= n 0)
    1
    (* n (factorial (- n 1)))))

(print "Factorial of 5 is:" (factorial 5))

;; String operations
(print "Cortado says:" (str "Welcome to " "scripting!"))

;; Final result - this should only show in verbose mode
(+ 2 3 4)