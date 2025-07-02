#!/usr/bin/env cortado

;; Getting Started with Cortado
;; A beginner-friendly introduction to Cortado programming

(print "=== Getting Started with Cortado ===")
(print)

;; === BASIC DATA TYPES ===
(print "1. Basic Data Types")

;; Numbers
(def my-number 42)
(def pi 3.14159)
(print "Number:" my-number)
(print "Pi:" pi)

;; Strings
(def greeting "Hello, Cortado!")
(def name "World")
(print "String:" greeting)

;; Booleans and nil
(def is-learning true)
(def is-expert false)
(def nothing nil)
(print "Boolean:" is-learning)
(print "Nil:" nothing)

;; Keywords (self-evaluating symbols)
(def status :active)
(def priority :high)
(print "Keyword:" status)
(print)

;; === BASIC ARITHMETIC ===
(print "2. Arithmetic Operations")

(print "Addition: (+ 1 2 3) =" (+ 1 2 3))
(print "Subtraction: (- 10 3) =" (- 10 3))
(print "Multiplication: (* 4 5) =" (* 4 5))
(print "Division: (/ 15 3) =" (/ 15 3))
(print "Modulo: (% 10 3) =" (% 10 3))
(print)

;; === VARIABLES ===
(print "3. Variables and Definitions")

(def x 10)
(def y 20)
(def sum (+ x y))
(print "x =" x)
(print "y =" y)
(print "sum = x + y =" sum)
(print)

;; === FUNCTIONS ===
(print "4. Functions")

;; Simple function
(defn square [n]
  (* n n))

(print "square(5) =" (square 5))

;; Function with multiple parameters
(defn greet [name age]
  (str "Hello " name ", you are " age " years old!"))

(print (greet "Alice" 25))

;; Anonymous function
(def add-ten (fn [x] (+ x 10)))
(print "add-ten(15) =" (add-ten 15))
(print)

;; === CONDITIONALS ===
(print "5. Conditional Logic")

(defn describe-number [n]
  (if (> n 0)
    "positive"
    (if (< n 0)
      "negative"
      "zero")))

(print "5 is" (describe-number 5))
(print "-3 is" (describe-number -3))
(print "0 is" (describe-number 0))

;; when - simpler than if when no else clause
(when (> x 5)
  (print "x is greater than 5"))

(print)

;; === LISTS ===
(print "6. Working with Lists")

(def numbers '(1 2 3 4 5))
(print "Numbers:" numbers)
(print "First:" (first numbers))
(print "Rest:" (rest numbers))

;; Adding to lists
(def more-numbers (cons 0 numbers))
(print "With 0 added:" more-numbers)
(print)

;; === RECURSION ===
(print "7. Recursion")

;; Factorial function
(defn factorial [n]
  (if (<= n 1)
    1
    (* n (factorial (- n 1)))))

(print "factorial(5) =" (factorial 5))

;; Fibonacci sequence
(defn fib [n]
  (if (<= n 1)
    n
    (+ (fib (- n 1)) (fib (- n 2)))))

(print "fib(8) =" (fib 8))
(print)

;; === COLLECTIONS ===
(print "8. Collections")

;; Lists
(def fruits '("apple" "banana" "orange"))
(print "Fruits:" fruits)

;; Vectors
(def colors ["red" "green" "blue"])
(print "Colors:" colors)

;; Maps
(def person {:name "John" :age 30 :city "New York"})
(print "Person:" person)
(print)

;; === HIGHER-ORDER FUNCTIONS ===
(print "9. Higher-Order Functions")

;; Function that takes another function
(defn apply-twice [f x]
  (f (f x)))

(print "apply-twice(inc, 5) =" (apply-twice inc 5))

;; Function that returns a function
(defn make-multiplier [n]
  (fn [x] (* n x)))

(def times-three (make-multiplier 3))
(print "times-three(7) =" (times-three 7))
(print)

;; === LOCAL BINDINGS ===
(print "10. Local Bindings")

(defn calculate-area [radius]
  (let [pi 3.14159
        r-squared (* radius radius)]
    (* pi r-squared)))

(print "Area of circle with radius 5:" (calculate-area 5))
(print)

;; === PRACTICE EXERCISES ===
(print "11. Practice Exercises")

;; Exercise 1: Write a function to check if a number is even
(defn even? [n]
  (= (% n 2) 0))

(print "Is 4 even?" (even? 4))
(print "Is 7 even?" (even? 7))

;; Exercise 2: Write a function to find the maximum of two numbers
(defn max-of-two [a b]
  (if (> a b) a b))

(print "max of 8 and 12:" (max-of-two 8 12))

;; Exercise 3: Write a function to reverse a list
(defn reverse-list [lst]
  (if (empty? lst)
    '()
    (cons (reverse-list (rest lst)) (first lst))))

; Note: This is a simplified reverse - real implementation is more complex

(print "Reversed (1 2 3): This is left as an exercise!")
(print)

(print "=== Congratulations! ===")
(print "You've learned the basics of Cortado programming!")
(print "Next steps:")
(print "- Try the REPL: cargo run")
(print "- Explore more examples in this directory")
(print "- Read the comprehensive guide: docs/HOW_TO_CODE_IN_CORTADO.md")