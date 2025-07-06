#!/usr/bin/env cortado

;; Functional Programming in Cortado - Fixed Version
;; Advanced functional programming patterns and techniques

(print "=== Functional Programming in Cortado ===")
(print)

;; Load functional programming utilities
(require 'core.functional)
(require 'core.seq)

;; === HIGHER-ORDER FUNCTIONS ===
(print "1. Higher-Order Functions")

;; Function composition
(defn inc [x] (+ x 1))
(defn double [x] (* x 2))
(defn square [x] (* x x))

;; Compose functions: f(g(x))
(def inc-then-double (comp inc double))
(print "inc-then-double(5):" (inc-then-double 5))

;; Multiple composition
(def process-number (comp3 inc double square))
(print "inc(double(square(3))):" (process-number 3))

;; Partial application
(def add-ten (partial1 + 10))
(print "add-ten(5):" (add-ten 5))

(def multiply-by-3 (partial1 * 3))
(print "multiply-by-3(7):" (multiply-by-3 7))
(print)

;; === PREDICATES AND TESTING ===
(print "2. Predicates and Testing")

;; Test all elements
(def all-even (every? even? '(2 4 6 8)))
(print "All even [2 4 6 8]:" all-even)

(def all-positive (every? positive? '(1 2 3 4)))
(print "All positive [1 2 3 4]:" all-positive)

;; Test any element
(def any-even (some even? '(1 3 5 6)))
(print "Any even in [1 3 5 6]:" any-even)

(def any-negative (some negative? '(1 2 3)))
(print "Any negative in [1 2 3]:" any-negative)

;; Predicate composition
(print "Is 7 odd?:" (odd? 7))
(print "Is 4 odd?:" (odd? 4))
(print)

;; === MAP, FILTER, REDUCE ===
(print "3. Map, Filter, Reduce - The Core Trio")

(def numbers '(1 2 3 4 5 6 7 8 9 10))
(print "Original:" numbers)

;; Map operations
(def doubled (map-list double numbers))
(print "Doubled: " doubled)

(def squared (map-list square numbers))
(print "Squared: " squared)

;; Filter operations
(def evens (filter-list even? numbers))
(print "Even numbers:" evens)

(def big-numbers (filter-list (fn [x] (> x 5)) numbers))
(print "Numbers > 5:" big-numbers)

;; Reduce operations
(def sum (reduce-list + 0 numbers))
(print "Sum of numbers:" sum)

(def product (reduce-list * 1 '(1 2 3 4 5)))
(print "Product of 1-5:" product)
(print)

;; === ADVANCED SEQUENCE OPERATIONS ===
(print "4. Advanced Sequence Operations")

;; Complex data processing pipeline
(def processed-numbers
  (reduce-list +
    0
    (filter-list even?
      (map-list square numbers))))
(print "Sum of squares of even numbers:" processed-numbers)

;; Take and drop operations
(def first-five (take 5 numbers))
(def skip-three (drop 3 numbers))
(print "First 5:" first-five)
(print "Skip first 3:" skip-three)
(print)

;; === CLOSURES ===
(print "5. Closures - Functions with Memory")

;; Function factories
(defn make-adder [n]
  (fn [x] (+ x n)))

(def add-five (make-adder 5))
(def add-hundred (make-adder 100))
(print "add-five(10):" (add-five 10))
(print "add-hundred(25):" (add-hundred 25))

;; Multiplier factory
(defn make-multiplier [factor]
  (fn [x] (* x factor)))

(def double-it (make-multiplier 2))
(def triple-it (make-multiplier 3))
(print "double-it(7):" (double-it 7))
(print "triple-it(8):" (triple-it 8))
(print)

;; === RECURSIVE PATTERNS ===
(print "6. Recursive Functional Patterns")

;; Simple fibonacci
(defn fib [n]
  (if (<= n 1)
    n
    (+ (fib (- n 1)) (fib (- n 2)))))

(print "Fibonacci(8):" (fib 8))

;; Tail-recursive sum
(defn sum-list [lst]
  (letrec [[sum-helper (fn [remaining acc]
                         (if (empty? remaining)
                           acc
                           (sum-helper (rest remaining) (+ acc (first remaining)))))]]
    (sum-helper lst 0)))

(print "Sum using tail recursion:" (sum-list '(1 2 3 4 5)))
(print)

;; === UTILITY FUNCTIONS ===
(print "7. Utility Functions")

;; Identity function
(print "identity(42):" (identity 42))

;; Constantly - always returns same value
(def always-true (constantly true))
(print "always-true(anything):" (always-true 123))

;; Sequence utilities
(print "Last element of [1 2 3 4]:" (last '(1 2 3 4)))
(print)

;; === CONCLUSION ===
(print "=== Functional Programming Demonstration Complete ===")
(print "Key concepts covered:")
(print "- Higher-order functions and composition")
(print "- Map, filter, reduce operations")
(print "- Predicates and testing")
(print "- Closures and function factories")
(print "- Recursive patterns")
(print "- Utility functions")
(print)
(print "Cortado supports powerful functional programming patterns!")