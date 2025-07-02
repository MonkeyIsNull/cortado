;; Edge Cases and Error Handling Tests
;; Tests boundary conditions and error scenarios

(print "=== EDGE CASES AND ERROR HANDLING TESTS ===")

;; === EMPTY AND NIL HANDLING ===
(print "Testing empty and nil handling...")

;; Nil comparisons
(assert-eq true (= nil nil))
(assert-eq false (= nil 0))
(assert-eq false (= nil false))
(assert-eq false (= nil ""))

;; Operations with nil
(assert-eq nil (first nil))
(assert-eq nil (rest nil))

;; Nil in arithmetic (should work or error gracefully)
;; Note: These might cause errors, but we test the behavior
;; (assert-eq 0 (+ nil 0))  ; This would likely error

;; Empty string operations
(assert-eq 0 (str-length ""))
(assert-eq "" (str))
(assert-eq "" (str ""))

(print "✓ Empty and nil handling")

;; === NUMERIC EDGE CASES ===
(print "Testing numeric edge cases...")

;; Zero operations
(assert-eq 0 (* 42 0))
(assert-eq 0 (* 0 42))
(assert-eq 0 (+ 0 0))
(assert-eq 0 (- 0 0))

;; Operations with zero
(assert-eq 5 (+ 5 0))
(assert-eq 5 (- 5 0))
(assert-eq -5 (- 0 5))
(assert-eq 0 (* 5 0))

;; Negative number operations
(assert-eq -1 (+ -3 2))
(assert-eq -5 (- -3 2))
(assert-eq -6 (* -3 2))
(assert-eq 6 (* -3 -2))

;; Large numbers (within float precision)
(def large-num 999999)
(assert-eq 1000000 (inc large-num))
(assert-eq 999998 (dec large-num))

;; Small fractional numbers
(assert-eq 1.1 (+ 1 0.1))
(assert-eq 0.9 (- 1 0.1))

(print "✓ Numeric edge cases")

;; === STRING EDGE CASES ===
(print "Testing string edge cases...")

;; Empty strings
(assert-eq "" "")
(assert-eq 0 (str-length ""))
(assert-eq "hello" (str "" "hello" ""))

;; Single character strings
(assert-eq 1 (str-length "a"))
(assert-eq "abc" (str "a" "b" "c"))

;; Numbers to strings
(assert-eq "0" (str 0))
(assert-eq "42" (str 42))
(assert-eq "-5" (str -5))

;; Boolean to strings
(assert-eq "true" (str true))
(assert-eq "false" (str false))

;; Nil to string
(assert-eq "nil" (str nil))

(print "✓ String edge cases")

;; === LIST EDGE CASES ===
(print "Testing list edge cases...")

;; Empty list operations
(def empty-list nil)
(assert-eq nil (first empty-list))
(assert-eq nil (rest empty-list))

;; Single element lists
(def single-list (list 42))
(assert-eq 42 (first single-list))
(assert-eq nil (rest single-list))
(assert-eq nil (first (rest single-list)))

;; Deeply nested lists
(def nested (list (list (list 1))))
(assert-eq 1 (first (first (first nested))))

;; Mixed type lists
(def mixed (list 1 "hello" true nil))
(assert-eq 1 (first mixed))
(assert-eq "hello" (first (rest mixed)))
(assert-eq true (first (rest (rest mixed))))
(assert-eq nil (first (rest (rest (rest mixed)))))

(print "✓ List edge cases")

;; === FUNCTION EDGE CASES ===
(print "Testing function edge cases...")

;; Functions with no parameters
(defn no-params [] 42)
(assert-eq 42 (no-params))

;; Functions that return nil
(defn returns-nil [] nil)
(assert-eq nil (returns-nil))

;; Functions that return other functions
(defn returns-function [] (fn [x] x))
(def returned-fn (returns-function))
(assert-eq 5 (returned-fn 5))

;; Simple non-recursive function test
(defn simple-identity [x] x)
(assert-eq 42 (simple-identity 42))

(print "✓ Function edge cases")

;; === CONDITIONAL EDGE CASES ===
(print "Testing conditional edge cases...")

;; Truthiness tests
(assert-eq "truthy" (if 1 "truthy" "falsy"))
(assert-eq "truthy" (if "hello" "truthy" "falsy"))
(assert-eq "truthy" (if '(1 2 3) "truthy" "falsy"))
(assert-eq "falsy" (if nil "truthy" "falsy"))
(assert-eq "falsy" (if false "truthy" "falsy"))

;; Nested conditionals
(assert-eq "inner-true" (if true (if true "inner-true" "inner-false") "outer-false"))
(assert-eq "outer-false" (if false (if true "inner-true" "inner-false") "outer-false"))

;; Conditionals without else clause
(assert-eq 42 (if true 42 nil))
(assert-eq nil (if false 42 nil))

(print "✓ Conditional edge cases")

;; === COMPARISON EDGE CASES ===
(print "Testing comparison edge cases...")

;; Equality with different types
(assert-eq false (= 1 "1"))
(assert-eq false (= 0 false))
(assert-eq false (= 0 nil))
(assert-eq false (= false nil))

;; Multiple equality
(assert-eq true (= 1 1 1 1))
(assert-eq false (= 1 1 1 2))

;; Self-comparison
(assert-eq true (= 42 42))
(assert-eq true (= "hello" "hello"))
(assert-eq true (= true true))

;; Ordering edge cases
(assert-eq false (< 1 1))
(assert-eq true (<= 1 1))  ; If <= exists
(assert-eq false (> 1 1))
;; (assert-eq true (>= 1 1))  ; If >= exists

;; Negative number comparisons
(assert-eq true (< -5 -3))
(assert-eq true (> -3 -5))
(assert-eq false (< -3 -5))

(print "✓ Comparison edge cases")

;; === MACRO EDGE CASES ===
(print "Testing macro edge cases...")

;; Macro with no arguments
(defmacro no-arg-macro [] `42)
(assert-eq 42 (no-arg-macro))

;; Macro that returns nil
(defmacro nil-macro [] `nil)
(assert-eq nil (nil-macro))

;; Macro with quoted arguments
(defmacro quote-arg [x] `(quote ~x))
(assert-eq 'unbound-symbol (quote-arg unbound-symbol))

;; Nested macro expansion
(defmacro outer-macro [x] `(when true ~x))
(assert-eq 42 (outer-macro 42))

(print "✓ Macro edge cases")

;; === VARIABLE SCOPING EDGE CASES ===
(print "Testing scoping edge cases...")

;; Variable shadowing
(def outer-var 1)
(defn test-shadowing []
  (def outer-var 2)
  outer-var)
(assert-eq 2 (test-shadowing))
(assert-eq 1 outer-var)  ; Original should be unchanged

;; Functions closing over variables
(def closed-var 100)
(defn make-closure []
  (fn [] closed-var))
(def closure-fn (make-closure))
(assert-eq 100 (closure-fn))

;; Update closed variable
(def closed-var 200)
;; Note: depending on implementation, this might or might not affect the closure

(print "✓ Scoping edge cases")

;; === PERFORMANCE EDGE CASES ===
(print "Testing performance edge cases...")

;; Simple non-recursive performance test
(defn simple-add [a b] (+ a b))
(assert-eq 3 (simple-add 1 2))

;; Large data structures (within reason)
(def big-list (list 1 2 3 4 5 6 7 8 9 10))
(assert-eq 1 (first big-list))
(assert-eq 10 (first (rest (rest (rest (rest (rest (rest (rest (rest (rest big-list)))))))))))

(print "✓ Performance edge cases")

(print "=== ALL EDGE CASE TESTS PASSED ===")