;; Test threading macros with require
(print "=== THREADING TEST ===")

;; Define assert-eq inline
(defn assert-eq [expected actual] 
  (if (= expected actual) 
    (print "  ✓ PASS:" expected "==" actual)
    (print "  ✗ FAIL: expected" expected "but got" actual)))

;; Load threading with require (fast loading)
(require [core.threading :as th])
(print "Threading module loaded")

;; Test functions
(defn inc [x] (+ x 1))
(defn double [x] (* x 2))

;; Test threading macro
(assert-eq 6 (th/-> 5 inc))
(assert-eq 12 (th/->2 5 inc double))

(print "Threading tests completed!")