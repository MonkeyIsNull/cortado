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

;; Test enhanced sequence operations
(require 'core.seq)

;; Test existing functions still work with new ones
(test-assert-eq (core.seq/map-list inc '(1 2 3)) '(2 3 4))
(test-assert-eq (core.seq/filter-list even? '(1 2 3 4)) '(2 4))

;; Test new sequence functions  
(test-assert-eq (core.seq/nth '(a b c d) 0) 'a)
(test-assert-eq (core.seq/nth '(a b c d) 2) 'c)
(test-assert-eq (core.seq/nth '(a b c d) 10) nil)

(test-assert-eq (core.seq/range 1 4) '(1 2 3))
(test-assert-eq (core.seq/range-from-zero 3) '(0 1 2))

(test-assert-eq (core.seq/interleave '(1 3 5) '(2 4 6)) '(1 2 3 4 5 6))

(test-assert-eq (core.seq/remove even? '(1 2 3 4 5)) '(1 3 5))

(test-assert-eq (core.seq/repeat 3 'x) '(x x x))
(test-assert-eq (core.seq/repeat 0 'x) '())

;; Integration tests - combining multiple new functions
(def test-data '(1 2 3 4 5 6))

;; Test apply with user-defined function  
(defn sum-all [& args]
  (if (empty? args) 0 (+ (first args) (apply sum-all (rest args)))))

(test-assert-eq (apply sum-all test-data) 21)

;; Test composition of new functions
(def process-list (core.functional/comp 
                   (core.functional/partial1 core.seq/map-list inc)
                   (core.functional/partial1 core.seq/filter-list even?)))

;; Should filter evens: (2 4 6), then increment: (3 5 7)
(test-assert-eq (process-list test-data) '(3 5 7))

;; Test string utilities
(require 'core.string)
(test-assert-eq (core.string/join ", " '("a" "b" "c")) "a, b, c")
(test-assert-eq (core.string/empty-string? "") true)
(test-assert-eq (core.string/empty-string? "hello") false)
(test-assert-eq (core.string/repeat-str "hi" 3) "hihihi")

;; Test math utilities  
(require 'core.math)
(test-assert-eq (core.math/pow 2 3) 8)
(test-assert-eq (core.math/factorial 4) 24)
(test-assert-eq (core.math/gcd 12 8) 4)
(test-assert-eq (core.math/sum '(1 2 3 4)) 10)
(test-assert-eq (core.math/average '(2 4 6)) 4)

(print "All new function tests passed!")
