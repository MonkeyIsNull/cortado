;; Load standard library functions  
(defn identity [x] x)
(defn assert-eq [expected actual]
  (if (= expected actual)
    (print "PASS: expected" expected "got" actual)
    (print "FAIL: expected" expected "got" actual)))

;; Simple tests
(print "Running manual tests...")
(assert-eq 42 (identity 42))
(assert-eq "hello" (identity "hello"))
(print "Manual tests completed!")