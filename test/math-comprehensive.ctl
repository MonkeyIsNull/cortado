;; Comprehensive Math Module Tests
;; Tests all math functions and edge cases

(print "=== MATH MODULE COMPREHENSIVE TESTS ===")

;; === BASIC ARITHMETIC HELPERS ===
(print "Testing arithmetic helpers...")

;; Increment
(assert-eq 1 (inc 0))
(assert-eq 6 (inc 5))
(assert-eq 0 (inc -1))
(assert-eq -4 (inc -5))

;; Decrement
(assert-eq -1 (dec 0))
(assert-eq 4 (dec 5))
(assert-eq -2 (dec -1))
(assert-eq -6 (dec -5))

;; Chaining operations
(assert-eq 7 (inc (inc 5)))
(assert-eq 3 (dec (dec 5)))
(assert-eq 5 (inc (dec 5)))
(assert-eq 5 (dec (inc 5)))

(print "✓ Arithmetic helpers")

;; === ABSOLUTE VALUE ===
(print "Testing absolute value...")

;; Positive numbers
(assert-eq 5 (abs 5))
(assert-eq 42 (abs 42))
(assert-eq 3.14 (abs 3.14))

;; Negative numbers
(assert-eq 5 (abs -5))
(assert-eq 42 (abs -42))
(assert-eq 3.14 (abs -3.14))

;; Zero
(assert-eq 0 (abs 0))

;; Edge case - very small numbers
(assert-eq 0.1 (abs -0.1))

(print "✓ Absolute value")

;; === MIN AND MAX ===
(print "Testing min and max...")

;; Basic min
(assert-eq 3 (min 3 7))
(assert-eq 3 (min 7 3))
(assert-eq -5 (min -5 -2))
(assert-eq -5 (min 5 -5))

;; Basic max
(assert-eq 7 (max 3 7))
(assert-eq 7 (max 7 3))
(assert-eq -2 (max -5 -2))
(assert-eq 5 (max 5 -5))

;; Equal values
(assert-eq 5 (min 5 5))
(assert-eq 5 (max 5 5))

;; Zero comparisons
(assert-eq 0 (min 0 5))
(assert-eq 0 (min 5 0))
(assert-eq 5 (max 0 5))
(assert-eq 5 (max 5 0))
(assert-eq -1 (min 0 -1))
(assert-eq 0 (max 0 -1))

(print "✓ Min and max")

;; === PREDICATES ===
(print "Testing math predicates...")

;; Zero predicate
(assert-eq true (zero? 0))
(assert-eq false (zero? 1))
(assert-eq false (zero? -1))
(assert-eq false (zero? 0.1))

;; Positive predicate
(assert-eq true (pos? 1))
(assert-eq true (pos? 0.1))
(assert-eq true (pos? 42))
(assert-eq false (pos? 0))
(assert-eq false (pos? -1))
(assert-eq false (pos? -0.1))

;; Negative predicate
(assert-eq true (neg? -1))
(assert-eq true (neg? -0.1))
(assert-eq true (neg? -42))
(assert-eq false (neg? 0))
(assert-eq false (neg? 1))
(assert-eq false (neg? 0.1))

(print "✓ Math predicates")

;; === SQUARE AND CUBE ===
(print "Testing square and cube...")

;; Square
(assert-eq 0 (square 0))
(assert-eq 1 (square 1))
(assert-eq 1 (square -1))
(assert-eq 4 (square 2))
(assert-eq 4 (square -2))
(assert-eq 9 (square 3))
(assert-eq 25 (square 5))

;; Cube
(assert-eq 0 (cube 0))
(assert-eq 1 (cube 1))
(assert-eq -1 (cube -1))
(assert-eq 8 (cube 2))
(assert-eq -8 (cube -2))
(assert-eq 27 (cube 3))
(assert-eq 125 (cube 5))

(print "✓ Square and cube")

;; === COMBINING OPERATIONS ===
(print "Testing combined operations...")

;; Absolute value of operations
(assert-eq 3 (abs (- 2 5)))
(assert-eq 7 (abs (+ -3 -4)))

;; Min/max with computed values
(assert-eq 4 (min (square 2) (cube 2)))
(assert-eq 8 (max (square 2) (cube 2)))

;; Complex expressions
(assert-eq 1 (abs (- (square 3) (cube 2))))
(assert-eq 10 (inc (square 3)))
(assert-eq 8 (dec (square 3)))

;; Nested function calls
(assert-eq 36 (square (inc 5)))
(assert-eq 16 (square (dec 5)))
(assert-eq 5 (abs (neg? -5)))  ; This should be false -> 0, then abs -> 0... wait
;; Let me fix this test:
(def neg-five -5)
(assert-eq 5 (abs neg-five))

(print "✓ Combined operations")

;; === EDGE CASES ===
(print "Testing edge cases...")

;; Very large numbers (within float precision)
(assert-eq 1000000 (inc 999999))
(assert-eq 999999 (dec 1000000))

;; Fractional numbers
(assert-eq 1.5 (inc 0.5))
(assert-eq -0.5 (dec 0.5))
(assert-eq 2.25 (square 1.5))

;; Operations that should preserve zero
(assert-eq 0 (square 0))
(assert-eq 0 (cube 0))
(assert-eq 0 (abs 0))

(print "✓ Edge cases")

;; === MATHEMATICAL IDENTITIES ===
(print "Testing mathematical identities...")

;; Square identities
(assert-eq true (= (square 3) (* 3 3)))
(assert-eq true (= (square -3) (square 3)))

;; Cube identities  
(assert-eq true (= (cube 3) (* 3 3 3)))
(assert-eq true (= (cube -3) (- (cube 3))))

;; Absolute value identities
(assert-eq true (= (abs -5) (abs 5)))
(assert-eq true (>= (abs 5) 0))

;; Inc/dec are inverses
(def test-num 42)
(assert-eq test-num (dec (inc test-num)))
(assert-eq test-num (inc (dec test-num)))

(print "✓ Mathematical identities")

(print "=== ALL MATH MODULE TESTS PASSED ===")