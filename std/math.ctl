;; Cortado Standard Library - Math Module
;; Mathematical helper functions

;; Basic arithmetic helpers
(defn inc [n] (+ n 1))
(defn dec [n] (- n 1))

;; Absolute value
(defn abs [n]
  (if (< n 0) (- n) n))

;; Min and max
(defn min [a b]
  (if (< a b) a b))

(defn max [a b]
  (if (> a b) a b))

;; Predicates
(defn zero? [n] (= n 0))
(defn pos? [n] (> n 0))
(defn neg? [n] (< n 0))

;; Square and cube
(defn square [n] (* n n))
(defn cube [n] (* n n n))

