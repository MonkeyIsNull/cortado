;; Simplified Cortado Standard Library
;; Works within current language limitations

;; Basic functions
(defn identity [x] x)
(defn inc [n] (+ n 1))
(defn dec [n] (- n 1))
(defn zero? [n] (= n 0))
(defn pos? [n] (> n 0))
(defn neg? [n] (< n 0))

;; Control flow macros  
(defmacro when [cond body] `(if ~cond ~body nil))
(defmacro unless [cond body] `(if ~cond nil ~body))

;; Utility functions
(defn min [a b] (if (< a b) a b))
(defn max [a b] (if (> a b) a b))
(defn abs [n] (if (neg? n) (- n) n))

;; Simple test
(defn test-result [name result expected] (if (= result expected) (print "✓" name) (print "✗" name)))

(print "Simplified core library loaded")