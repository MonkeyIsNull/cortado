;; Comprehensive Core Language Tests
;; Tests all fundamental Cortado language features

(print "=== CORE LANGUAGE COMPREHENSIVE TESTS ===")

;; === BASIC DATA TYPES ===
(print "Testing basic data types...")

;; Numbers
(assert-eq 42 42)
(assert-eq 3.14 3.14)
(assert-eq -5 -5)

;; Strings  
(assert-eq "hello" "hello")
(assert-eq "" "")

;; Booleans
(assert-eq true true)
(assert-eq false false)

;; Nil
(assert-eq nil nil)

;; Keywords
(assert-eq :keyword :keyword)

(print "✓ Basic data types")

;; === ARITHMETIC OPERATIONS ===
(print "Testing arithmetic...")

;; Addition
(assert-eq 3 (+ 1 2))
(assert-eq 10 (+ 1 2 3 4))
(assert-eq 0 (+))

;; Subtraction  
(assert-eq 1 (- 3 2))
(assert-eq -5 (- 0 5))
(assert-eq -1 (- 1 2))

;; Multiplication
(assert-eq 6 (* 2 3))
(assert-eq 24 (* 2 3 4))
(assert-eq 1 (*))

;; Division
(assert-eq 2 (/ 6 3))
(assert-eq 1 (/ 10 2 5))

(print "✓ Arithmetic operations")

;; === COMPARISON OPERATIONS ===
(print "Testing comparisons...")

;; Equality
(assert-eq true (= 1 1))
(assert-eq false (= 1 2))
(assert-eq true (= "a" "a"))
(assert-eq true (= 1 1 1))
(assert-eq false (= 1 1 2))

;; Inequality
(assert-eq false (not= 1 1))
(assert-eq true (not= 1 2))

;; Ordering
(assert-eq true (< 1 2))
(assert-eq false (< 2 1))
(assert-eq true (> 2 1))
(assert-eq false (> 1 2))

(print "✓ Comparison operations")

;; === VARIABLE DEFINITIONS ===
(print "Testing variable definitions...")

(def x 42)
(assert-eq 42 x)

(def y "hello")
(assert-eq "hello" y)

(def z nil)
(assert-eq nil z)

(print "✓ Variable definitions")

;; === FUNCTION DEFINITIONS ===
(print "Testing function definitions...")

;; Simple function
(defn double [n] (* n 2))
(assert-eq 10 (double 5))

;; Multiple parameters
(defn add3 [a b c] (+ a b c))
(assert-eq 6 (add3 1 2 3))

;; Anonymous functions
(def triple (fn [n] (* n 3)))
(assert-eq 15 (triple 5))

;; Zero parameter function
(defn get-42 [] 42)
(assert-eq 42 (get-42))

(print "✓ Function definitions")

;; === CONDITIONAL EXPRESSIONS ===
(print "Testing conditionals...")

;; Basic if
(assert-eq "yes" (if true "yes" "no"))
(assert-eq "no" (if false "yes" "no"))
(assert-eq nil (if false "yes" nil))

;; Nested conditions
(assert-eq "inner" (if true (if true "inner" "outer") "no"))

(print "✓ Conditional expressions")

;; === LISTS AND LIST OPERATIONS ===
(print "Testing lists...")

;; List creation
(def my-list (list 1 2 3))
(assert-eq 1 (first my-list))
(assert-eq 2 (first (rest my-list)))

;; Cons operation
(def consed (cons 0 my-list))
(assert-eq 0 (first consed))
(assert-eq 1 (first (rest consed)))

;; Empty lists
(assert-eq nil (first nil))
(assert-eq nil (rest nil))

(print "✓ List operations")

;; === BOOLEAN LOGIC ===
(print "Testing boolean logic...")

;; not operation
(assert-eq false (not true))
(assert-eq true (not false))
(assert-eq true (not nil))
(assert-eq false (not 1))

(print "✓ Boolean logic")

;; === LEXICAL SCOPING ===
(print "Testing lexical scoping...")

;; Variable shadowing
(def outer 1)
(defn test-scope [] (do (def outer 2) outer))
(assert-eq 2 (test-scope))
(assert-eq 1 outer)

;; Closure test
(defn make-adder [x] (fn [y] (+ x y)))
(def add5 (make-adder 5))
(assert-eq 8 (add5 3))

(print "✓ Lexical scoping")

;; === LETREC BINDINGS ===
(print "Testing letrec...")

;; Simple binding
(assert-eq 42 (letrec [[x 42]] x))

;; Multiple bindings
(assert-eq 7 (letrec [[x 3] [y 4]] (+ x y)))

;; Function binding
(assert-eq 10 (letrec [[double (fn [n] (* n 2))]] (double 5)))

(print "✓ Letrec bindings")

;; === STRING OPERATIONS ===
(print "Testing string operations...")

;; String concatenation
(assert-eq "hello world" (str "hello" " " "world"))
(assert-eq "42" (str 42))

;; String length
(assert-eq 5 (str-length "hello"))
(assert-eq 0 (str-length ""))

(print "✓ String operations")

(print "=== ALL CORE LANGUAGE TESTS PASSED ===")