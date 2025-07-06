#!/usr/bin/env cortado

;; Macros in Cortado
;; Metaprogramming and code transformation

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
; Note: We can't eval this directly in this example
(print)

;; === SIMPLE MACRO DEFINITION ===
(print "4. Defining Simple Macros")

;; unless macro - opposite of when
(defmacro my-unless [condition body]
  `(if ~condition nil ~body))

;; Test the macro
(my-unless false (print "This will print because condition is false"))
(my-unless true (print "This will NOT print because condition is true"))

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

;; Multiple condition macro (cond)
(def score 85)
(def grade
  (cond
    (>= score 90) "A"
    (>= score 80) "B"
    (>= score 70) "C"
    (>= score 60) "D"
    "F"))

(print "Score" score "gets grade:" grade)
(print)

;; === CUSTOM UTILITY MACROS ===
(print "6. Custom Utility Macros")

;; debug macro - prints value and returns it
(defmacro debug [expr]
  `(let [result ~expr]
     (print "DEBUG:" '~expr "=>" result)
     result))

;; Test debug macro
(def debug-result (debug (+ 5 7)))
(print "Debug result:" debug-result)

;; time macro (simplified)
(defmacro simple-time [expr]
  `(do
     (print "Timing:" '~expr)
     (let [start (now)
           result ~expr
           end (now)]
       (print "Elapsed: approximately" (- end start) "units")
       result)))

; Note: This is conceptual as 'now' function would need to be implemented
(print)

;; === ASSERTION MACROS ===
(print "7. Assertion and Testing Macros")

;; Simple assert macro
(defmacro my-assert [condition message]
  `(if ~condition
     true
     (do
       (print "ASSERTION FAILED:" ~message)
       (print "Condition:" '~condition)
       false)))

;; Test assertions
(my-assert (= 2 (+ 1 1)) "Basic math should work")
(my-assert (> 5 3) "5 should be greater than 3")

;; Test equality macro
(defmacro assert-eq [expected actual]
  `(let [exp ~expected
         act ~actual]
     (if (= exp act)
       (print "PASS:" '~actual "=>" act)
       (print "FAIL: expected" exp "but got" act))))

(assert-eq 4 (+ 2 2))
(assert-eq 10 (* 2 5))
(print)

;; === LOOPING MACROS ===
(print "8. Looping and Iteration Macros")

;; Simple repeat macro
(defmacro repeat-n [n body]
  `(defn repeat-helper [count]
     (when (> count 0)
       ~body
       (repeat-helper (- count 1))))
   `(repeat-helper ~n))

;; dotimes-like macro (simplified)
(defmacro my-dotimes [binding body]
  (let [var (first binding)
        n (first (rest binding))]
    `(defn dotimes-helper [~var max]
       (when (< ~var max)
         ~body
         (dotimes-helper (+ ~var 1) max)))
     `(dotimes-helper 0 ~n)))

; Note: These are conceptual examples
(print "Loop macros defined (conceptual)")
(print)

;; === CONDITIONAL COMPILATION ===
(print "9. Conditional Compilation")

;; Feature flag macro
(defmacro when-feature [feature body]
  `(if (feature-enabled? ~feature)
     ~body
     nil))

;; Debug mode macro
(defmacro debug-only [body]
  `(when-feature :debug ~body))

; Note: feature-enabled? would need to be implemented
(print "Conditional compilation macros defined")
(print)

;; === ADVANCED MACRO TECHNIQUES ===
(print "10. Advanced Macro Techniques")

;; Macro that generates multiple functions
(defmacro def-math-ops [name op]
  `(do
     (defn ~name [x y] (~op x y))
     (defn ~(symbol (str name "-3")) [x y z] (~op (~op x y) z))))

;; Generate addition functions
; (def-math-ops my-add +)
; (def-math-ops my-multiply *)

;; Variable argument macro
(defmacro my-and [& conditions]
  (if (empty? conditions)
    true
    (if (= (count conditions) 1)
      (first conditions)
      `(if ~(first conditions)
         (my-and ~@(rest conditions))
         false))))

; Note: ~@ is splice-unquote (not fully implemented in this example)
(print "Advanced macro techniques demonstrated")
(print)

;; === MACRO HYGIENE ===
(print "11. Macro Hygiene and Best Practices")

;; Hygienic macro - avoids variable capture
(defmacro safe-swap [a b]
  `(let [temp# ~a]   ; temp# generates unique symbol
     (set! ~a ~b)
     (set! ~b temp#)))

;; Non-hygienic macro (can cause problems)
(defmacro unsafe-swap [a b]
  `(let [temp ~a]    ; 'temp' might conflict with user variables
     (set! ~a ~b)
     (set! ~b temp)))

(print "Macro hygiene principles:")
(print "  - Use unique symbols (gensym) for temporary variables")
(print "  - Be careful about variable capture")
(print "  - Test macros thoroughly")
(print "  - Keep macros simple when possible")
(print)

;; === MACRO DEBUGGING ===
(print "12. Debugging Macros")

;; Use macroexpand to see what a macro generates
(print "Debugging with macroexpand:")
(print "  Original: (my-unless false 42)")
(print "  Expands to:" (macroexpand '(my-unless false 42)))

(print "  Original: (cond (> 5 3) 'big (< 5 3) 'small)")
; (print "  Expands to:" (macroexpand '(cond (> 5 3) "big" (< 5 3) "small")))

(print)

;; === WHEN TO USE MACROS ===
(print "13. When to Use Macros")

(print "Use macros for:")
(print "  - Creating new control flow constructs")
(print "  - Eliminating repetitive code patterns") 
(print "  - Domain-specific languages (DSLs)")
(print "  - Compile-time computation")
(print "  - Code generation")
(print)

(print "Avoid macros for:")
(print "  - Simple functions (use functions instead)")
(print "  - Runtime computation")
(print "  - When functions would work just as well")
(print)

;; === REAL-WORLD MACRO EXAMPLES ===
(print "14. Real-World Macro Applications")

;; Configuration macro
(defmacro defconfig [name & key-value-pairs]
  `(def ~name 
     ~(apply map key-value-pairs)))

; (defconfig app-config
;   :host "localhost"
;   :port 8080
;   :debug true)

;; Test suite macro
(defmacro deftest [test-name & body]
  `(defn ~test-name []
     (print "Running test:" '~test-name)
     ~@body
     (print "Test completed:" '~test-name)))

; (deftest test-arithmetic
;   (assert-eq 4 (+ 2 2))
;   (assert-eq 6 (* 2 3)))

(print "Real-world macro patterns demonstrated")
(print)

;; === COMPARISON: FUNCTIONS VS MACROS ===
(print "15. Functions vs Macros")

;; Function version
(defn add-func [a b]
  (+ a b))

;; Macro version (not necessary here!)
(defmacro add-macro [a b]
  `(+ ~a ~b))

(print "Function call: (add-func 3 4) =>" (add-func 3 4))
(print "Macro call: (add-macro 3 4) =>" (add-macro 3 4))
(print "Macro expands to:" (macroexpand '(add-macro 3 4)))

(print)
(print "Rule of thumb: Use functions unless you need compile-time")
(print "transformation or special evaluation semantics.")
(print)

(print "=== Macro Mastery ===")
(print "You've learned:")
(print "- What macros are and how they work")
(print "- Quoting and quasiquoting")
(print "- Defining custom macros")
(print "- Control flow and utility macros")
(print "- Macro hygiene and best practices")
(print "- When to use macros vs functions")
(print "- Real-world macro applications")
(print)
(print "Macros are powerful tools for metaprogramming")
(print "Use them wisely to create cleaner, more expressive code!")
(print)
(print "Next: Try examples/06-real-world-app.lisp for a complete application!")