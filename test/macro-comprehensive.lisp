;; Comprehensive Macro System Tests
;; Tests quoting, quasiquoting, macros, and code generation

(print "=== MACRO SYSTEM COMPREHENSIVE TESTS ===")

;; === QUOTING ===
(print "Testing quote...")

;; Basic quoting
(assert-eq 'x (quote x))
(assert-eq '(+ 1 2) (quote (+ 1 2)))

;; Quote prevents evaluation
(def x 42)
(assert-eq 42 x)
(assert-eq 'x (quote x))

;; Quote with lists
(assert-eq '(a b c) (quote (a b c)))
(assert-eq '(1 2 3) (quote (1 2 3)))

;; Nested quotes
(assert-eq '(quote x) (quote (quote x)))

(print "✓ Quote")

;; === QUASIQUOTE AND UNQUOTE ===
(print "Testing quasiquote...")

;; Basic quasiquote (acts like quote when no unquote)
(assert-eq '(a b c) `(a b c))

;; Unquote evaluation
(def num 42)
(assert-eq '(value 42) `(value ~num))

;; Multiple unquotes
(def a 1)
(def b 2) 
(assert-eq '(1 plus 2) `(~a plus ~b))

;; Unquote in different positions
(assert-eq '(42 middle end) `(~num middle end))
(assert-eq '(start 42 end) `(start ~num end))
(assert-eq '(start middle 42) `(start middle ~num))

;; Nested quasiquote expressions
;; (assert-eq '(list 1 2 3) `(list ~@(quote (1 2 3))))  ; Unquote-splicing not yet implemented

(print "✓ Quasiquote and unquote")

;; === SIMPLE MACROS ===
(print "Testing simple macros...")

;; Basic macro definition
(defmacro simple-macro [x] `(+ ~x 1))
(assert-eq 43 (simple-macro 42))

;; Macro vs function - macro doesn't evaluate arguments
(defmacro quote-arg [x] `(quote ~x))
(assert-eq 'y (quote-arg y))  ; y not evaluated

;; Control flow macro
(defmacro my-when [cond body] `(if ~cond ~body nil))
(assert-eq 42 (my-when true 42))
(assert-eq nil (my-when false 42))

(print "✓ Simple macros")

;; === STANDARD LIBRARY MACROS ===
(print "Testing stdlib macros...")

;; when macro (from std library)
(assert-eq 99 (when true 99))
(assert-eq nil (when false 99))

;; unless macro  
(assert-eq nil (unless true 99))
(assert-eq 99 (unless false 99))

;; Test that macros work with complex expressions
(def test-var 0)
(when (= 1 1) (def test-var 42))
(assert-eq 42 test-var)

(print "✓ Standard library macros")

;; === MACRO EXPANSION ===
(print "Testing macro expansion...")

;; macroexpand shows expanded form
(defmacro test-expand [x] `(* ~x 2))
(assert-eq '(* 5 2) (macroexpand '(test-expand 5)))

;; Expansion of when
(assert-eq '(if true 42 nil) (macroexpand '(when true 42)))

;; Expansion of unless
(assert-eq '(if false nil 42) (macroexpand '(unless false 42)))

(print "✓ Macro expansion")

;; === COMPLEX MACROS ===
(print "Testing complex macros...")

;; Macro that generates multiple expressions
(defmacro def-and-inc [name val]
  `(def ~name (+ ~val 1)))

(def-and-inc test-inc 41)
(assert-eq 42 test-inc)

;; Macro with multiple parameters
(defmacro swap-args [op a b] `(~op ~b ~a))
(assert-eq -1 (swap-args - 3 2))  ; becomes (- 2 3)
(assert-eq 6 (swap-args * 2 3))   ; becomes (* 3 2)

;; Conditional macro generation
(defmacro make-predicate [name test]
  `(defn ~name [x] ~test))

;; This would define a function, test separately
;; (make-predicate positive? (> x 0))
;; (assert-eq true (positive? 5))

(print "✓ Complex macros")

;; === MACRO HYGIENE AND SCOPING ===
(print "Testing macro scoping...")

;; Macro captures lexical environment
(def global-var 100)
(defmacro use-global [] `global-var)
(assert-eq 100 (use-global))

;; Local variables in macro expansion
(defmacro with-local [val body]
  `(let [local-var ~val] ~body))  ; If let works

;; For now, test simpler scoping
(defmacro add-to-global [x] `(+ global-var ~x))
(assert-eq 105 (add-to-global 5))

(print "✓ Macro scoping")

;; === RECURSIVE AND NESTED MACROS ===
(print "Testing macro composition...")

;; Macro using another macro
(defmacro double-when [cond val]
  `(when ~cond (* ~val 2)))

(assert-eq 10 (double-when true 5))
(assert-eq nil (double-when false 5))

;; Nested macro calls
(assert-eq 84 (when true (double-when true 42)))

(print "✓ Macro composition")

;; === ERROR CASES AND EDGE CASES ===
(print "Testing macro edge cases...")

;; Macro with no arguments
(defmacro get-pi [] `3.14159)
(assert-eq 3.14159 (get-pi))

;; Macro that returns a constant
(defmacro always-true [] `true)
(assert-eq true (always-true))

;; Macro with symbol generation
(defmacro def-temp [val] `(def temp-var ~val))
(def-temp 123)
(assert-eq 123 temp-var)

(print "✓ Macro edge cases")

;; === QUOTE VARIATIONS ===
(print "Testing quote variations...")

;; Different quote forms should be equivalent
(assert-eq (quote x) 'x)
(assert-eq (quote (a b)) '(a b))

;; Quasiquote without unquote acts like quote
(assert-eq '(a b c) `(a b c))
(assert-eq (quote (a b c)) `(a b c))

(print "✓ Quote variations")

(print "=== ALL MACRO SYSTEM TESTS PASSED ===")