;; Test sequences with require  
(print "=== SEQUENCES TEST ===")

;; Define assert-eq inline
(defn assert-eq [expected actual] 
  (if (= expected actual) 
    (print "  ✓ PASS:" expected "==" actual)
    (print "  ✗ FAIL: expected" expected "but got" actual)))

;; Load sequences with require (fast loading)
(require [core.sequences :as seq])
(print "Sequences module loaded")

;; Test functions
(defn inc [x] (+ x 1))

;; Test mapv
(assert-eq '(2 3 4) (seq/mapv inc '(1 2 3)))

;; Test reverse
(assert-eq '(3 2 1) (seq/reverse '(1 2 3)))

;; Test distinct  
(assert-eq '(1 2 3) (seq/distinct '(1 2 1 3 2)))

(print "Sequences tests completed!")