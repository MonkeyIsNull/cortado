;; Simple threading test without namespace prefixes
(print "=== THREADING SIMPLE TEST ===")

;; Define assert-eq inline
(defn assert-eq [expected actual] 
  (if (= expected actual) 
    (print "  ✓ PASS:" expected "==" actual)
    (print "  ✗ FAIL: expected" expected "but got" actual)))

;; Load threading module
(require [core.threading :as th])
(print "Threading module loaded")

;; Test functions
(defn inc [x] (+ x 1))

;; Test threading macro WITHOUT namespace prefix
(assert-eq 6 (-> 5 inc))

(print "Simple threading test completed!")