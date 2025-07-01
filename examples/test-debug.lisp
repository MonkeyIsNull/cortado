;; Debug test
(print "Debug test start")
(print (+ 1 2))
(print "Basic math works")

;; Test if assert-eq is available
(defn assert-eq [expected actual]
  (if (= expected actual)
    (print "PASS:" expected "==" actual)
    (print "FAIL: expected" expected "got" actual)))

(print "Defined assert-eq")
(assert-eq 3 (+ 1 2))
(print "Assert works")
(print "Debug test complete")