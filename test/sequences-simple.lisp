;; Simple sequences test - only test functions without dependencies  
(print "=== SEQUENCES SIMPLE TEST ===")

;; Define assert-eq inline
(defn assert-eq [expected actual] 
  (if (= expected actual) 
    (print "  ✓ PASS:" expected "==" actual)
    (print "  ✗ FAIL: expected" expected "but got" actual)))

;; Load sequences module  
(require [core.sequences :as seq])
(print "Sequences module loaded")

;; Test functions
(defn inc [x] (+ x 1))

;; Test only mapv (which works)
(assert-eq '(2 3 4) (mapv inc '(1 2 3)))

;; Test empty list
(assert-eq '() (mapv inc '()))

(print "Simple sequences test completed!")