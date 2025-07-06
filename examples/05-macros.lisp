#!/usr/bin/env cortado

;; Macros in Cortado - Simple Working Version
(print "=== Macros: Code that Writes Code ===")
(print)

;; Load control flow macros
(require 'core.control)

;; === WHAT ARE MACROS? ===
(print "1. Understanding Macros")

(print "Macros are functions that transform code at compile time.")
(print "They take code as input and return transformed code.")
(print "The result is then evaluated as normal Cortado code.")
(print)

;; === QUOTING - PREVENTING EVALUATION ===
(print "2. Quoting: Treating Code as Data")

;; Normal evaluation
(print "Normal evaluation: (+ 1 2) =>" (+ 1 2))

;; Quoted - prevents evaluation
(print "Quoted: '(+ 1 2) =>" '(+ 1 2))
(print "With quote function:" (quote (+ 1 2)))

;; More examples
(def code-as-data '(print "Hello" "World"))
(print "Code as data:" code-as-data)
(print "First element of code:" (first code-as-data))
(print "Arguments:" (rest code-as-data))
(print)

;; === QUASIQUOTE AND UNQUOTE ===
(print "3. Quasiquote: Selective Evaluation")

;; Basic quasiquote
(def x 42)
(print "Quasiquote without unquote: `(+ 1 2) =>" `(+ 1 2))
(print "Quasiquote with unquote: `(+ 1 ~x) =>" `(+ 1 ~x))

;; Building expressions
(def operation '+)
(def operand 5)
(def generated-code `(~operation 1 ~operand))
(print "Generated code:" generated-code)
(print)

;; === DEFINING SIMPLE MACROS ===
(print "4. Defining Simple Macros")

;; Simple unless macro
(defmacro my-unless [condition body]
  `(if ~condition nil ~body))

;; Test the macro
(print "This will print because condition is false")
(my-unless false (print "Executed through macro!"))

;; Macro expansion
(print "Macro expansion of (my-unless false 42):")
(print (macroexpand '(my-unless false 42)))
(print)

;; === CONTROL FLOW MACROS ===
(print "5. Control Flow Macros")

;; when-not macro
(when-not false
  (do
    (print "when-not: This prints when condition is false")
    42))

;; if-not macro  
(print "if-not result:" 
  (if-not false "condition was false" "condition was true"))

;; cond macro (simplified)
(def score 85)
(def grade
  (cond
    (>= score 90) "A"
    (>= score 80) "B"
    "C or below"))

(print "Score" score "gets grade:" grade)
(print)

;; === CUSTOM UTILITY MACROS ===
(print "6. Custom Utility Macros")

;; debug macro - prints value and returns it
(defmacro debug [expr]
  `(let [result ~expr]
     (do
       (print "DEBUG:" '~expr "=>" result)
       result)))

;; Test debug macro
(def debug-result (debug (+ 5 7)))
(print "Debug result:" debug-result)
(print)

;; === SIMPLE TESTING MACROS ===
(print "7. Simple Testing Macros")

;; Assert-like macro
(defmacro check [expr expected]
  `(let [result ~expr]
     (if (= result ~expected)
       (print "PASS:" '~expr "=>" result)
       (print "FAIL:" '~expr "expected" ~expected "got" result))))

;; Test the check macro
(check (+ 2 2) 4)
(check (* 2 5) 10)
(print)

;; === CONCLUSION ===
(print "=== Macro Demonstration Complete ===")
(print "Key concepts covered:")
(print "- Quoting and quasiquoting")
(print "- Defining simple macros")
(print "- Control flow macros")
(print "- Utility macros")
(print "- Testing macros")
(print)
(print "Macros provide powerful metaprogramming capabilities!")