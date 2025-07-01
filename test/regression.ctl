;; Regression Test Suite
;; Critical tests that must pass for Cortado to be functional
;; These tests can actually run and verify functionality

(print "=== CORTADO REGRESSION TEST SUITE ===")

;; Load minimal required functions
(defn assert-eq [expected actual]
  (if (= expected actual)
    (print "PASS:" expected "==" actual)
    (print "FAIL: expected" expected "but got" actual)))

;; === CRITICAL ARITHMETIC ===
(print "Testing critical arithmetic...")
(assert-eq 3 (+ 1 2))
(assert-eq 1 (- 3 2))
(assert-eq 6 (* 2 3))
(assert-eq 2 (/ 6 3))

;; === CRITICAL COMPARISONS ===
(print "Testing critical comparisons...")
(assert-eq true (= 1 1))
(assert-eq false (= 1 2))
(assert-eq true (< 1 2))
(assert-eq true (> 2 1))

;; === CRITICAL VARIABLES ===
(print "Testing critical variables...")
(def test-var 42)
(assert-eq 42 test-var)

;; === CRITICAL FUNCTIONS ===
(print "Testing critical functions...")
(defn add-one [x] (+ x 1))
(assert-eq 6 (add-one 5))

;; === CRITICAL CONDITIONALS ===
(print "Testing critical conditionals...")
(assert-eq "yes" (if true "yes" "no"))
(assert-eq "no" (if false "yes" "no"))

;; === CRITICAL LISTS ===
(print "Testing critical lists...")
(def test-list (list 1 2 3))
(assert-eq 1 (first test-list))
(assert-eq 2 (first (rest test-list)))

;; === CRITICAL BOOLEAN LOGIC ===
(print "Testing critical boolean logic...")
(assert-eq false (not true))
(assert-eq true (not false))

;; === CRITICAL STRINGS ===
(print "Testing critical strings...")
(assert-eq "hello world" (str "hello" " " "world"))
(assert-eq 5 (str-length "hello"))

;; === CRITICAL MATH FUNCTIONS ===
(print "Testing critical math functions...")
(defn inc [n] (+ n 1))
(defn dec [n] (- n 1))
(defn abs [n] (if (< n 0) (- n) n))

(assert-eq 6 (inc 5))
(assert-eq 4 (dec 5))
(assert-eq 5 (abs -5))
(assert-eq 5 (abs 5))

;; === CRITICAL PREDICATES ===
(print "Testing critical predicates...")
(defn zero? [n] (= n 0))
(defn pos? [n] (> n 0))
(defn neg? [n] (< n 0))

(assert-eq true (zero? 0))
(assert-eq false (zero? 1))
(assert-eq true (pos? 5))
(assert-eq false (pos? -5))
(assert-eq true (neg? -5))
(assert-eq false (neg? 5))

;; === CRITICAL CLOSURES ===
(print "Testing critical closures...")
(defn make-adder [x] (fn [y] (+ x y)))
(def add10 (make-adder 10))
(assert-eq 15 (add10 5))

;; === CRITICAL MACROS ===
(print "Testing critical macros...")
(defmacro when [cond body] `(if ~cond ~body nil))
(assert-eq 42 (when true 42))
(assert-eq nil (when false 42))

;; === CRITICAL QUOTING ===
(print "Testing critical quoting...")
(assert-eq 'x (quote x))
(def y 42)
(assert-eq '(+ y 1) `(+ ~'y 1))

;; === FILE I/O CRITICAL TESTS ===
(print "Testing critical file I/O...")
(write-file "regression-test.txt" "test content")
(assert-eq "test content" (read-file "regression-test.txt"))

;; === TIME CRITICAL TESTS ===
(print "Testing critical time functions...")
(def time1 (now-ms))
(sleep-ms 1)
(def time2 (now-ms))
(assert-eq true (> time2 time1))

;; === SUMMARY ===
(print "")
(print "=== REGRESSION TESTS COMPLETED ===")
(print "If you see this message and no FAIL messages above,")
(print "then all critical Cortado functionality is working!")
(print "=== CORTADO IS OPERATIONAL ===")