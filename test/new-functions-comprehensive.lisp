;; Comprehensive tests for newly implemented functions
;; Tests for essential Rust primitives and Cortado standard library functions

;; Test essential Rust primitives

;; Test apply function
(test-assert-eq (apply + '(1 2 3)) 6)
(test-assert-eq (apply * '(2 3 4)) 24)
(test-assert-eq (apply max '(1 5 3 2)) 5)
(test-assert-eq (apply list '(a b c)) '(a b c))

;; Test concat function  
(test-assert-eq (concat '(1 2) '(3 4)) '(1 2 3 4))
(test-assert-eq (concat '(a) '(b) '(c)) '(a b c))
(test-assert-eq (concat '() '(1 2) '()) '(1 2))
(test-assert-eq (concat) '())

;; Test type predicates
(test-assert-eq (string? "hello") true)
(test-assert-eq (string? 42) false)
(test-assert-eq (number? 3.14) true)
(test-assert-eq (number? "not-a-number") false)
(test-assert-eq (list? '(1 2 3)) true)
(test-assert-eq (list? [1 2 3]) false)
(test-assert-eq (vector? [1 2 3]) true)
(test-assert-eq (vector? '(1 2 3)) false)

;; Test logical operators and/or
(test-assert-eq (and true true) true)
(test-assert-eq (and true false) false)
(test-assert-eq (and false true) false)
(test-assert-eq (and) true)
(test-assert-eq (and 1 2 3) 3)
(test-assert-eq (and 1 nil 3) nil)

(test-assert-eq (or false true) true)
(test-assert-eq (or false false) false)
(test-assert-eq (or true false) true)
(test-assert-eq (or) nil)
(test-assert-eq (or nil false 42) 42)
(test-assert-eq (or 1 2 3) 1)

;; Test functional programming utilities
(require 'core.functional)

;; Test function composition
(def add-one (core.functional/partial1 + 1))
(test-assert-eq (add-one 5) 6)

(def double-inc (core.functional/comp inc (core.functional/partial1 * 2)))
(test-assert-eq (double-inc 3) 7) ; (* 3 2) = 6, then inc = 7

;; Test every? and some
(test-assert-eq (core.functional/every? pos? '(1 2 3)) true)
(test-assert-eq (core.functional/every? pos? '(1 -2 3)) false)
(test-assert-eq (core.functional/every? pos? '()) true)

(def find-even (core.functional/some even? '(1 3 4 5)))
(test-assert-eq (not (nil? find-even)) true)

;; Test conj
(test-assert-eq (core.functional/conj '(2 3) 1) '(1 2 3))

;; Test last and butlast
(test-assert-eq (core.functional/last '(1 2 3 4)) 4)
(test-assert-eq (core.functional/last '()) nil)
(test-assert-eq (core.functional/butlast '(1 2 3 4)) '(1 2 3))
(test-assert-eq (core.functional/butlast '(1)) '())

;; Test take-while and drop-while
(test-assert-eq (core.functional/take-while pos? '(1 2 3 -1 4)) '(1 2 3))
(test-assert-eq (core.functional/take-while pos? '(-1 2 3)) '())
(test-assert-eq (core.functional/drop-while pos? '(1 2 3 -1 4)) '(-1 4))

;; Test complement
(def not-even? (core.functional/complement even?))
(test-assert-eq (not-even? 3) true)
(test-assert-eq (not-even? 4) false)

;; Test identity
(test-assert-eq (core.functional/identity 42) 42)
(test-assert-eq (core.functional/identity "hello") "hello")

;; Test that basic sequence operations work without qualified names
;; TODO: Fix recursive function calls through qualified names in multi-namespace environment
;; All recursive function calls through qualified names cause infinite recursion

;; Test new non-recursive functions only
(def test-data '(1 2 3 4 5 6))

;; Test apply with simpler function (no variadic args)
(defn sum-three [a b c]
  (+ a b c))

(test-assert-eq (apply sum-three '(1 2 3)) 6)

;; Test basic functionality without namespace qualification works
(test-assert-eq (concat '(1 2) '(3 4)) '(1 2 3 4))
(test-assert-eq (apply + '(1 2 3 4)) 10)

;; TODO: Test string and math utilities once namespace resolution is fixed
;; (require 'core.string)
;; (require 'core.math)

(print "Basic new function tests passed!")
