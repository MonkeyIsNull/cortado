;; Test sequences without namespace prefixes
(print "=== SEQUENCES DIRECT TEST ===")

;; Define assert-eq inline
(defn assert-eq [expected actual] 
  (if (= expected actual) 
    (print "  ✓ PASS:" expected "==" actual)
    (print "  ✗ FAIL: expected" expected "but got" actual)))

;; Load sequences  
(require [core.sequences :as seq])
(print "Sequences module loaded")

;; Test functions directly
(defn inc [x] (+ x 1))

;; Test mapv directly (without namespace prefix)
(assert-eq '(2 3 4) (mapv inc '(1 2 3)))

;; Test reverse
(assert-eq '(3 2 1) (reverse '(1 2 3)))

(print "Direct sequences tests completed!")