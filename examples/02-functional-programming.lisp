#!/usr/bin/env cortado

;; Functional Programming in Cortado - Simple Working Version
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

(def inc-then-double (comp inc double))
(print "inc-then-double(5):" (inc-then-double 5))
(print)

;; === MAP, FILTER, REDUCE ===
(print "2. Map, Filter, Reduce - The Core Trio")

(def numbers '(1 2 3 4 5))
(print "Original:" numbers)

(def doubled (map-list double numbers))
(print "Doubled:" doubled)

(def evens (filter-list even? numbers))
(print "Even numbers:" evens)

(def sum (reduce-list + 0 numbers))
(print "Sum:" sum)
(print)

;; === CLOSURES ===
(print "3. Closures - Function Factories")

(defn make-adder [n]
  (fn [x] (+ x n)))

(def add-five (make-adder 5))
(print "add-five(10):" (add-five 10))
(print)

;; === SIMPLE RECURSION ===
(print "4. Simple Recursion")

(defn factorial [n]
  (if (= n 0) 1 (* n (factorial (- n 1)))))

(print "factorial(5):" (factorial 5))
(print)

(print "=== Functional Programming Complete ===")
(print "Cortado supports functional programming!")