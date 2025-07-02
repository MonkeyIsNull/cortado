;; Simple test to verify module loading works
(require [test])

(print "=== SIMPLE TEST ===")

;; Reset test stats
(reset-test-stats)

;; Test basic arithmetic
(assert-eq 4 (+ 2 2))
(assert-eq 6 (* 2 3))
(assert-eq true (= 5 5))

;; Test our new threading macro
(require [core.threading])
(defn inc [x] (+ x 1))
(assert-eq 6 (-> 5 inc))

;; Test sequence functions with require
(require [core.sequences])
(assert-eq '(2 3 4) (mapv inc '(1 2 3)))

(print "Test summary:" (test-summary))