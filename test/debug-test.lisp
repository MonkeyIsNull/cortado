;; Debug test to find the hanging issue
(load "std/test.lisp")
(load "std/core/sequences.lisp")

(print "=== DEBUG TEST ===")

(reset-test-stats)

(defn inc [x] (+ x 1))
(print "inc defined")

(def result (mapv inc '(1 2 3)))
(print "mapv result:" result)

(def expected '(2 3 4))
(print "expected:" expected)

(print "comparing lists...")
(print "equal?" (= expected result))

(print "calling assert-eq...")
(assert-eq expected result)

(print "Test completed!")