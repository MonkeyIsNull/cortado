;; Tests for core module

(print "Testing core module...")

;; Test identity
(assert-eq 42 (identity 42))
(assert-eq "hello" (identity "hello"))

;; Test constantly
(def always-5 (constantly 5))
(assert-eq 5 (always-5 10))

;; Test boolean predicates
(assert-eq true (true? true))
(assert-eq false (true? false))
(assert-eq true (nil? nil))
(assert-eq false (nil? 0))

(print "Core tests completed!")