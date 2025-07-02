(print "=== NAMESPACE COMPREHENSIVE TESTS ===")

;; Basic namespace switching
(print "Testing basic namespace operations...")
(ns user)
(def user-var 42)
(assert-eq user-var 42)

(ns test.ns1)
(def ns1-var 100)
(assert-eq ns1-var 100)

;; Namespace isolation
(print "Testing namespace isolation...")
(ns test.ns2)
(def ns1-var 200) ; Same name, different namespace
(assert-eq ns1-var 200)

;; Fully qualified access
(print "Testing fully qualified access...")
(assert-eq test.ns1/ns1-var 100)
(assert-eq test.ns2/ns1-var 200)
(assert-eq user/user-var 42)

;; Function definitions across namespaces
(print "Testing function definitions...")
(ns test.functions)
(defn add [x y] (+ x y))
(defn multiply [x y] (* x y))
(assert-eq (add 2 3) 5)
(assert-eq (multiply 4 5) 20)

;; Accessing functions from other namespaces
(ns test.caller)
(assert-eq (test.functions/add 10 20) 30)
(assert-eq (test.functions/multiply 3 7) 21)

;; Core namespace fallback
(print "Testing core namespace fallback...")
(ns test.core-fallback)
(assert-eq (+ 1 2) 3)
(assert-eq (first '(1 2 3)) 1)

;; Switching back to previously defined namespaces
(print "Testing namespace switching...")
(ns test.ns1)
(assert-eq ns1-var 100)
(def another-var 300)

(ns test.ns2)
(assert-eq ns1-var 200)
(assert-eq test.ns1/another-var 300)

;; Default namespace behavior
(print "Testing default namespace behavior...")
(ns user) ; Reset to user namespace
(def final-test "complete")
(assert-eq final-test "complete")

;; Namespace aliasing with :as
(print "Testing namespace aliasing...")
(require [core.seq :as s])
(def test-list '(1 2 3 4))
(assert-eq (s/length test-list) 4)
(assert-eq (s/map-list (fn [x] (* x 2)) '(1 2)) '(2 4))
(assert-eq (s/reduce-list + 0 '(1 2 3)) 6)

;; Test all recursive functions work with aliases
(assert-eq (s/filter-list (fn [x] (> x 2)) test-list) '(3 4))
(assert-eq (s/reverse-list '(a b c)) '(c b a))

;; Multiple aliases for same namespace
(require [core.seq :as seq])
(assert-eq (seq/length test-list) 4)
(assert-eq (s/length test-list) 4) ; Both aliases should work

;; Test more edge cases for aliasing
(assert-eq (s/reduce-list * 1 '(2 3 4)) 24)

(print "=== NAMESPACE TESTS COMPLETED SUCCESSFULLY ===")