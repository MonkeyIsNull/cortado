;; Basic test without module loading
(print "=== BASIC TEST ===")

;; Define assert-eq inline
(defn assert-eq [expected actual] 
  (if (= expected actual) 
    (print "  ✓ PASS:" expected "==" actual)
    (print "  ✗ FAIL: expected" expected "but got" actual)))

;; Test basic arithmetic
(assert-eq 4 (+ 2 2))
(assert-eq 6 (* 2 3))
(assert-eq true (= 5 5))

;; Test basic functions
(defn inc [x] (+ x 1))
(assert-eq 6 (inc 5))

;; Test list operations
(assert-eq 1 (first '(1 2 3)))
(assert-eq '(2 3) (rest '(1 2 3)))
(assert-eq '(0 1 2 3) (cons 0 '(1 2 3)))

(print "All basic tests completed!")