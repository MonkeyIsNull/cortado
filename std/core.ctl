;; Cortado Standard Library - Core Module
;; Fundamental macros and functions

;; Identity and constant functions
(defn identity [x] x)
(defn constantly [x] (fn [y] x))
(defn complement [f] (fn [x] (not (f x))))

;; Control flow macros
(defmacro when [cond body] 
  `(if ~cond ~body nil))

(defmacro unless [cond body] 
  `(if ~cond nil ~body))

;; Simple cond macro - handles pairs of condition/result
(defmacro cond [c1 r1 c2 r2]
  `(if ~c1 ~r1 (if ~c2 ~r2 nil)))

;; Simple assertion function (not macro to avoid complexity)
(defn assert-eq [expected actual]
  (if (= expected actual)
    (print "PASS: expected" expected "got" actual)
    (print "FAIL: expected" expected "got" actual)))

;; Boolean operations
(defn true? [x] (= x true))
(defn false? [x] (= x false))
(defn nil? [x] (= x nil))
(defn some? [x] (not (nil? x)))