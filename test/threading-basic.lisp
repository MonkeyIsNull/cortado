;; Basic threading test - no complex conditions
(print "=== THREADING BASIC TEST ===")

;; Define assert-eq inline
(defn assert-eq [expected actual] 
  (if (= expected actual) 
    (print "  ✓ PASS:" expected "==" actual)
    (print "  ✗ FAIL: expected" expected "but got" actual)))

;; Load threading module
(require [core.threading :as th])
(print "Threading module loaded")

;; Test simple inc function
(defn inc [x] (+ x 1))

;; Test threading with simple function only
(assert-eq 6 (-> 5 inc))

;; Test threading with arithmetic
(assert-eq 7 (-> 5 (+ 2)))

(print "Basic threading test completed!")