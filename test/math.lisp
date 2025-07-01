;; Tests for math module

(print "Testing math module...")

;; Test inc and dec
(assert-eq 6 (inc 5))
(assert-eq 4 (dec 5))

;; Test abs
(assert-eq 5 (abs 5))
(assert-eq 5 (abs -5))
(assert-eq 0 (abs 0))

;; Test min and max
(assert-eq 3 (min 3 7))
(assert-eq 7 (max 3 7))

;; Test predicates
(assert-eq true (zero? 0))
(assert-eq false (zero? 1))
(assert-eq true (pos? 5))
(assert-eq false (pos? -5))

;; Test square and cube
(assert-eq 9 (square 3))
(assert-eq 27 (cube 3))

(print "Math tests completed!")