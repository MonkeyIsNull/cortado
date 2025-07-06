#!/usr/bin/env cortado

;; Functional Programming in Cortado
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
(print "inc-then-double(5):" (inc-then-double 5))  ; inc(double(5)) = inc(10) = 11

;; Multiple composition
(def process-number (comp3 inc double square))
(print "inc(double(square(3))):" (process-number 3))  ; inc(double(9)) = inc(18) = 19

;; Partial application
(def add-ten (partial1 + 10))
(def multiply-by (partial1 * 3))
(print "add-ten(5):" (add-ten 5))
(print "multiply-by-3(7):" (multiply-by 7))
(print)

;; === PREDICATES AND TESTING ===
(print "2. Predicates and Testing")

(defn even? [x] (= (% x 2) 0))
(defn positive? [x] (> x 0))

;; Test all elements
(def all-even (every? even? '(2 4 6 8)))
(def all-positive (every? positive? '(1 2 3 4)))
(print "All even [2 4 6 8]:" all-even)
(print "All positive [1 2 3 4]:" all-positive)

;; Test any element
(def any-even (some even? '(1 3 5 6)))
(def any-negative (some negative? '(1 2 3)))
(print "Any even in [1 3 5 6]:" any-even)
(print "Any negative in [1 2 3]:" any-negative)

;; Complement - invert predicate
(def odd? (complement even?))
(print "Is 7 odd?:" (odd? 7))
(print "Is 4 odd?:" (odd? 4))
(print)

;; === MAP, FILTER, REDUCE ===
(print "3. Map, Filter, Reduce - The Core Trio")

(def numbers '(1 2 3 4 5 6 7 8 9 10))

;; Map - transform each element
(def doubled (map-list double numbers))
(def squared (map-list square numbers))
(print "Original:" numbers)
(print "Doubled: " doubled)
(print "Squared: " squared)

;; Filter - select elements
(def evens (filter-list even? numbers))
(def big-numbers (filter-list (fn [x] (> x 5)) numbers))
(print "Even numbers:" evens)
(print "Numbers > 5:" big-numbers)

;; Reduce - combine elements
(def sum (reduce-list + 0 numbers))
(def product (reduce-list * 1 '(1 2 3 4 5)))
(print "Sum of numbers:" sum)
(print "Product of 1-5:" product)
(print)

;; === ADVANCED SEQUENCE OPERATIONS ===
(print "4. Advanced Sequence Operations")

;; Chain operations together
(def processed-numbers
  (reduce-list +
    0
    (filter-list even?
      (map-list square numbers))))
(print "Sum of squares of even numbers:" processed-numbers)

;; Alternative using functional composition (simplified)
; Note: partial1 only takes 2 args, so complex composition is commented out
; (def process-pipeline
;   (comp3 
;     (partial1 reduce-list +)
;     (partial1 filter-list even?)
;     (partial1 map-list square)))

(print "Functional composition techniques available but complex")

;; Take and drop operations
(def first-five (take 5 numbers))
(def skip-three (drop 3 numbers))
(print "First 5:" first-five)
(print "Skip first 3:" skip-three)
(print)

;; === CLOSURES ===
(print "5. Closures - Functions with Memory")

;; Counter and accumulator closures
; Note: set! is not implemented in Cortado, so these are conceptual examples
(print "Closure examples (set! not implemented):")
(print "- Stateful closures require mutable variables")
(print "- Pure functional alternatives use parameters")

;; Function factory
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

;; Tail-recursive sum (using letrec for local function)
(defn sum-list [lst]
  (letrec [[sum-helper (fn [remaining acc]
                         (if (empty? remaining)
                           acc
                           (sum-helper (rest remaining) (+ acc (first remaining)))))]]
    (sum-helper lst 0)))

(print "Sum using tail recursion:" (sum-list '(1 2 3 4 5)))

;; Tree processing
(defn process-nested [data processor]
  (if (list? data)
    (map-list (fn [item] (process-nested item processor)) data)
    (processor data)))

(def nested-numbers '(1 (2 3) ((4 5) 6)))
; (def processed-nested (process-nested nested-numbers inc))
; (print "Processed nested:" processed-nested)

;; Fibonacci with memoization (conceptual)
(defn make-memoized-fib []
  (let [cache '()]
    (defn fib [n]
      (if (<= n 1)
        n
        (+ (fib (- n 1)) (fib (- n 2)))))))

(print)

;; === UTILITY FUNCTIONS ===
(print "7. Utility Functions")

;; Identity function
(print "identity(42):" (identity 42))

;; Constantly - always returns same value
(def always-true (constantly true))
(print "always-true(anything):" (always-true 123))

;; Juxt - apply multiple functions to same argument (not implemented)
; (def get-stats (juxt3 min max length))
; (print "Stats of [1 5 3 9 2]:" (get-stats '(1 5 3 9 2)))
(print "Juxt functionality not yet implemented")

;; Sequence utilities
(print "Last element of [1 2 3 4]:" (last '(1 2 3 4)))
; (print "All but last [1 2 3 4]:" (butlast '(1 2 3 4)))
(print "butlast function not yet implemented")

;; Take-while and drop-while (not implemented)
; (def numbers-with-negatives '(1 2 3 -1 4 5))
; (print "Take while positive:" (take-while positive? numbers-with-negatives))
; (print "Drop while positive:" (drop-while positive? numbers-with-negatives))
(print "take-while and drop-while functions not yet implemented")
(print)

;; === FUNCTION COMPOSITION PATTERNS ===
(print "8. Advanced Composition Patterns")

;; Pipeline of transformations
(defn data-pipeline [data]
  (reduce-list + 0
    (filter-list positive?
      (map-list (fn [x] (- x 5)) data))))

(print "Data pipeline result:" (data-pipeline '(6 7 8 9 10)))

;; Conditional processing
(defn conditional-process [data condition processor]
  (map-list 
    (fn [item]
      (if (condition item)
        (processor item)
        item))
    data))

(def selectively-doubled 
  (conditional-process '(1 2 3 4 5 6) even? double))
(print "Selectively doubled evens:" selectively-doubled)
(print)

;; === REAL-WORLD EXAMPLE ===
(print "9. Real-World Example: Data Analysis")

;; Student data processing
(def students '({:name "Alice" :grade 85 :subject "Math"}
               {:name "Bob" :grade 92 :subject "Math"}  
               {:name "Carol" :grade 78 :subject "Math"}
               {:name "Dave" :grade 88 :subject "Math"}))

;; Extract grades
(defn get-grade [student] (:grade student))

;; Calculate statistics (simplified)
(defn analyze-grades [students]
  (let [grades (map-list get-grade students)]
    {:count (length grades)
     :sum (reduce-list + 0 grades)
     :passing (length (filter-list (fn [g] (>= g 80)) grades))}))

; (print "Grade analysis:" (analyze-grades students))

(print)
(print "=== Functional Programming Mastery ===")
(print "You've learned:")
(print "- Higher-order functions and composition")
(print "- Map, filter, reduce patterns")
(print "- Closures and function factories")
(print "- Recursive functional patterns")
(print "- Real-world data processing")
(print)
(print "Next: Try example03-data-processing.lisp for advanced pipelines!")