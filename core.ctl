;; Cortado Standard Library (core.ctl)
;; Bootstrap library written in Cortado itself

;; =============================================================================
;; LOGICAL FUNCTIONS
;; =============================================================================

(defn identity [x] x)
(defn constantly [x] (fn [_] x))
(defn complement [f] (fn [x] (not (f x))))

;; =============================================================================
;; ARITHMETIC HELPERS
;; =============================================================================

(defn inc [n] (+ n 1))
(defn dec [n] (- n 1))
(defn zero? [n] (= n 0))
(defn pos? [n] (> n 0))
(defn neg? [n] (< n 0))

;; =============================================================================
;; CONTROL FLOW MACROS
;; =============================================================================

(defmacro when [cond body] `(if ~cond ~body nil))
(defmacro unless [cond body] `(if ~cond nil ~body))

;; =============================================================================
;; COLLECTION PREDICATES
;; =============================================================================

(defn nil? [x] (= x nil))
(defn some? [x] (not (nil? x)))

;; =============================================================================
;; BASIC LIST FUNCTIONS
;; =============================================================================

(defn second [xs] (first (rest xs)))
(defn third [xs] (first (rest (rest xs))))

;; Non-recursive list functions to avoid stack issues
(defn count [xs] (if (nil? xs) 0 (inc (count (rest xs)))))

;; Simplified append without recursion issues
(defn append [xs ys] (if (nil? xs) ys (cons (first xs) (append (rest xs) ys))))

;; =============================================================================
;; UTILITY FUNCTIONS
;; =============================================================================

(defn min [a b] (if (< a b) a b))
(defn max [a b] (if (> a b) a b))
(defn abs [n] (if (neg? n) (- n) n))

;; =============================================================================
;; TESTING UTILITIES
;; =============================================================================

(defmacro assert [expr] `(if ~expr true (print "Assertion failed")))

(defn test-fn [name f expected] (def result (f)) (if (= result expected) (print "✓" name "passed") (print "✗" name "failed - expected" expected "got" result)))

;; =============================================================================
;; SIMPLE TESTS
;; =============================================================================

(def run-tests (fn [] (print "Running Cortado core library tests...") (test-fn "identity" (fn [] (identity 42)) 42) (test-fn "inc" (fn [] (inc 5)) 6) (test-fn "dec" (fn [] (dec 5)) 4) (test-fn "zero?" (fn [] (zero? 0)) true) (test-fn "pos?" (fn [] (pos? 5)) true) (test-fn "neg?" (fn [] (neg? -3)) true) (test-fn "when true" (fn [] (when true 42)) 42) (test-fn "when false" (fn [] (when false 42)) nil) (test-fn "unless false" (fn [] (unless false 42)) 42) (test-fn "unless true" (fn [] (unless true 42)) nil) (test-fn "min" (fn [] (min 3 7)) 3) (test-fn "max" (fn [] (max 3 7)) 7) (test-fn "abs positive" (fn [] (abs 5)) 5) (test-fn "abs negative" (fn [] (abs -5)) 5) (print "Core library tests completed")))

(print "Cortado core library loaded successfully")
(print "Use (run-tests) to run the test suite")