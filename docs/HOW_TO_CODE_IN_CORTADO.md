# How to Code in Cortado ☕️

> A Comprehensive Guide to Cortado Programming

Cortado is a functional programming language with Lisp-like syntax, implemented in Rust. This guide covers everything you need to know to write effective Cortado code, from basic syntax to advanced patterns.

## Table of Contents

- [Getting Started](#getting-started)
- [Basic Syntax](#basic-syntax)
- [Data Types](#data-types)
- [Variables and Functions](#variables-and-functions)
- [Control Flow](#control-flow)
- [Collections and Sequences](#collections-and-sequences)
- [Functional Programming](#functional-programming)
- [Threading Macros](#threading-macros)
- [Namespaces and Modules](#namespaces-and-modules)
- [Macros](#macros)
- [Error Handling](#error-handling)
- [Common Patterns](#common-patterns)
- [Best Practices](#best-practices)

## Getting Started

### Running Cortado

```bash
# Start interactive REPL
cargo run

# Run a script file
cargo run script.lisp

# Evaluate expression directly
cargo run -- -e "(+ 1 2 3)"

# Run with verbose output
cargo run -v script.lisp
```

### REPL Commands

```
:quit, :q          Exit REPL
:help, :h          Show help
:env               Show environment bindings  
:reload            Reload init file
:load <file>       Load and evaluate file
```

## Basic Syntax

Cortado uses S-expression syntax where code is data:

```lisp
;; This is a comment

;; Function calls: (function arg1 arg2 ...)
(+ 1 2 3)          ; => 6
(* 2 3 4)          ; => 24
(print "Hello!")   ; Prints "Hello!"

;; Nested expressions
(+ (* 2 3) (- 8 2))  ; => 12
```

## Data Types

### Numbers

```lisp
42           ; Integer
3.14         ; Float
-5           ; Negative number
```

### Strings

```lisp
"hello"      ; String literal
""           ; Empty string
"Multi
line"        ; Multi-line string
```

### Booleans and Nil

```lisp
true         ; Boolean true
false        ; Boolean false
nil          ; Null/nothing value
```

### Keywords

```lisp
:keyword     ; Keyword (starts with colon)
:name        ; Often used as keys
:type        ; Self-evaluating
```

### Collections

```lisp
;; Lists (linked lists)
'(1 2 3)           ; Quoted list
(list 1 2 3)       ; Created with list function

;; Vectors (arrays)
[1 2 3]            ; Vector literal
(vector 1 2 3)     ; Created with vector function

;; Maps (dictionaries)
{:a 1 :b 2}        ; Map literal
(map :a 1 :b 2)    ; Created with map function
```

## Variables and Functions

### Defining Variables

```lisp
(def x 42)                    ; Define variable
(def greeting "Hello, World!")
(def pi 3.14159)
```

### Defining Functions

```lisp
;; Simple function
(defn greet [name]
  (str "Hello, " name "!"))

;; Function with multiple parameters
(defn add [x y]
  (+ x y))

;; Function with multiple expressions (implicit do)
(defn process-data [data]
  (print "Processing...")
  (let [result (* data 2)]
    (print "Result:" result)
    result))

;; Anonymous functions
(def add5 (fn [x] (+ x 5)))
(def multiply (fn [x y] (* x y)))
```

### Recursive Functions

```lisp
;; Factorial
(defn factorial [n]
  (if (= n 0)
    1
    (* n (factorial (- n 1)))))

;; Fibonacci
(defn fib [n]
  (if (<= n 1)
    n
    (+ (fib (- n 1)) (fib (- n 2)))))

;; List length
(defn length [lst]
  (if (empty? lst)
    0
    (+ 1 (length (rest lst)))))
```

### Closures

```lisp
;; Function that returns a function
(defn make-adder [x]
  (fn [y] (+ x y)))

(def add10 (make-adder 10))
(add10 5)  ; => 15

;; Counter closure
(defn make-counter []
  (let [count 0]
    (fn []
      (set! count (+ count 1))
      count)))
```

## Control Flow

### Conditional Expressions

```lisp
;; if expression
(if (> 5 3)
  "greater"
  "not greater")  ; => "greater"

;; when (if without else)
(when (> x 0)
  (print "Positive")
  (* x 2))

;; unless (inverted when)
(unless (zero? x)
  (print "Not zero")
  (/ 100 x))
```

### Advanced Control Flow

```lisp
;; cond for multiple conditions
(cond
  (< x 0) "negative"
  (= x 0) "zero"
  (> x 0) "positive")

;; case for exact matching
(case day
  1 "Monday"
  2 "Tuesday"
  3 "Wednesday"
  "Unknown day")

;; condp with predicate
(condp = (type value)
  :number "It's a number"
  :string "It's a string"
  :list   "It's a list"
  "Unknown type")
```

### Logical Operators

```lisp
;; and - short-circuit logical and
(and true false true)  ; => false
(and 1 2 3)           ; => 3

;; or - short-circuit logical or
(or false nil 42)     ; => 42
(or false false)      ; => false
```

## Collections and Sequences

### List Operations

```lisp
;; Creating lists
(def numbers '(1 2 3 4 5))
(def words (list "hello" "world"))

;; Accessing elements
(first numbers)    ; => 1
(rest numbers)     ; => (2 3 4 5)
(last numbers)     ; => 5

;; Adding elements
(cons 0 numbers)   ; => (0 1 2 3 4 5)
(conj numbers 6)   ; => (6 1 2 3 4 5) - prepends to list
```

### Sequence Functions

```lisp
;; Load sequence utilities
(require [core.seq :as s])

;; Map - transform each element
(s/map-list inc '(1 2 3))           ; => (2 3 4)
(s/map-list str '(1 2 3))           ; => ("1" "2" "3")

;; Filter - select elements
(s/filter-list even? '(1 2 3 4))   ; => (2 4)
(s/filter-list pos? '(-1 0 1 2))   ; => (1 2)

;; Reduce - combine elements
(s/reduce-list + 0 '(1 2 3))       ; => 6
(s/reduce-list * 1 '(1 2 3 4))     ; => 24

;; Other sequence operations
(s/length '(1 2 3))                ; => 3
(s/reverse-list '(1 2 3))          ; => (3 2 1)
(s/take 3 '(1 2 3 4 5))           ; => (1 2 3)
(s/drop 2 '(1 2 3 4 5))           ; => (3 4 5)
```

### Advanced Sequence Operations

```lisp
;; Load sequences utilities
(require [core.sequences :as seq])

;; Partition - split into chunks
(seq/partition 2 '(1 2 3 4 5 6))   ; => ((1 2) (3 4) (5 6))

;; Distinct - remove duplicates
(seq/distinct '(1 2 2 3 1 4))      ; => (1 2 3 4)

;; MapV - eager map (vs lazy map)
(seq/mapv inc '(1 2 3))            ; => (2 3 4)
```

## Functional Programming

### Higher-Order Functions

```lisp
(require [core.functional :as fn])

;; Function composition
(def inc-double (fn/comp inc double))
(inc-double 5)  ; => 11 (inc(double(5)))

;; Partial application
(def add10 (fn/partial1 + 10))
(add10 5)  ; => 15

;; Apply multiple functions to same input
(def stats (fn/juxt2 min max))
(stats '(1 5 3 9 2))  ; => (1 9)
```

### Predicates and Testing

```lisp
;; Test all elements
(fn/every? even? '(2 4 6))     ; => true
(fn/every? pos? '(1 -1 3))     ; => false

;; Test any element
(fn/some even? '(1 3 4 5))     ; => true
(fn/some neg? '(1 2 3))        ; => nil

;; Complement - invert predicate
(def odd? (fn/complement even?))
(odd? 3)  ; => true
```

### Utility Functions

```lisp
;; Identity - returns input unchanged
(fn/identity 42)  ; => 42

;; Constantly - always returns same value
(def always-zero (fn/constantly 0))
(always-zero 1 2 3)  ; => 0

;; Sequence utilities
(fn/last '(1 2 3))          ; => 3
(fn/butlast '(1 2 3))       ; => (1 2)
(fn/take-while pos? '(1 2 -1 3))   ; => (1 2)
(fn/drop-while neg? '(-1 -2 1 2))  ; => (1 2)
```

## Threading Macros

Threading macros dramatically improve code readability by eliminating nested function calls.

### Thread-First (->)

Inserts the result as the **first** argument of the next function:

```lisp
(require [core.threading :as t])

;; Without threading:
(inc (double (+ 5 3)))  ; => 17

;; With thread-first:
(t/->3 5
       (+ 3)     ; 5 + 3 = 8
       double    ; 8 * 2 = 16  
       inc)      ; 16 + 1 = 17

;; String processing
(t/->2 "hello"
       (str " world")   ; "hello" + " world"
       (str "!"))       ; "hello world" + "!"
```

### Thread-Last (->>)

Inserts the result as the **last** argument of the next function:

```lisp
;; List processing with thread-last
(t/->>3 '(1 2 3 4 5)
        (s/map-list inc)      ; (2 3 4 5 6)
        (s/filter-list even?) ; (2 4 6)
        (s/reduce-list +))    ; 12

;; Mathematical pipeline
(t/->>2 10
        (* 2)     ; (* 2 10) = 20
        (+ 5))    ; (+ 5 20) = 25
```

### When to Use Which

- Use `->` for **object-oriented style**: `obj.method1().method2()`
- Use `->>` for **functional pipelines**: data flowing through transformations

## Namespaces and Modules

### Creating Namespaces

```lisp
;; Switch to a namespace
(ns my.app)

;; Define things in this namespace
(def config {:host "localhost" :port 8080})
(defn start-server [] 
  (print "Starting server on" (:host config) ":" (:port config)))

;; Create utility namespaces
(ns utils.math)
(defn square [x] (* x x))
(defn cube [x] (* x x x))
```

### Using Namespaces

```lisp
;; Load namespace
(require 'core.seq)
(core.seq/map-list inc '(1 2 3))

;; Load with alias for cleaner code
(require [core.seq :as s])
(s/map-list inc '(1 2 3))         ; Much cleaner!
(s/filter-list even? '(1 2 3 4))  ; Readable
(s/reduce-list + 0 '(1 2 3))      ; Concise
```

### Namespace Organization

```lisp
;; Main application
(ns app.main
  (:require [app.config :as config]
            [app.database :as db]
            [app.routes :as routes]))

;; Configuration
(ns app.config)
(def settings {:db-host "localhost"
               :db-port 5432})

;; Database
(ns app.database)
(defn connect [] ...)
(defn query [sql] ...)

;; Routes
(ns app.routes)
(defn handle-request [req] ...)
```

## Macros

Macros transform code at compile time, enabling powerful metaprogramming.

### Quoting and Unquoting

```lisp
;; Quote prevents evaluation
'(+ 1 2)           ; => (+ 1 2) - not evaluated
(quote (+ 1 2))    ; Same as above

;; Quasiquote allows selective evaluation
`(+ 1 ~(+ 1 1))    ; => (+ 1 2)
(quasiquote (+ 1 ~(unquote (+ 1 1))))  ; Same as above
```

### Defining Macros

```lisp
;; Simple macro
(defmacro unless [condition body]
  `(if ~condition nil ~body))

;; Usage
(unless false (print "This will print"))

;; Macro expansion
(macroexpand '(unless false 42))  ; => (if false nil 42)
```

### Control Flow Macros

```lisp
;; Load control flow macros
(require [core.control :as ctrl])

;; when-not
(ctrl/when-not false
  (print "Condition is false")
  42)  ; => 42

;; if-let - bind and test
(ctrl/if-let [x (find-item items)]
  (process x)
  (handle-not-found))

;; when-let - bind and test without else
(ctrl/when-let [result (compute-value)]
  (print "Got result:" result)
  (save-result result))
```

## Error Handling

### Assertions and Testing

```lisp
;; Simple assertions
(assert (= 2 (+ 1 1)))
(assert (pos? 5))

;; Test assertions for development
(defn test-function []
  (assert-eq 4 (+ 2 2))
  (assert-eq "hello" (str "hel" "lo"))
  (print "All tests passed!"))
```

### Defensive Programming

```lisp
;; Check preconditions
(defn divide [x y]
  (assert (not (zero? y)) "Cannot divide by zero")
  (/ x y))

;; Validate inputs
(defn process-list [lst]
  (assert (list? lst) "Input must be a list")
  (assert (not (empty? lst)) "List cannot be empty")
  (s/map-list process-item lst))
```

## Common Patterns

### Data Processing Pipeline

```lisp
(require [core.seq :as s])
(require [core.threading :as t])

;; Process a dataset
(defn analyze-data [data]
  (t/->>3 data
          (s/filter-list valid?)        ; Remove invalid entries
          (s/map-list normalize)        ; Normalize values
          (s/map-list calculate-score)  ; Calculate scores
          (s/reduce-list +)))           ; Sum total

;; Alternative without threading macros
(defn analyze-data-verbose [data]
  (s/reduce-list +
    (s/map-list calculate-score
      (s/map-list normalize
        (s/filter-list valid? data)))))
```

### Configuration and Setup

```lisp
(ns app.config)

;; Configuration map
(def config
  {:database {:host "localhost"
              :port 5432
              :name "myapp"}
   :server   {:port 8080
              :host "0.0.0.0"}
   :logging  {:level :info
              :file "app.log"}})

;; Accessor functions
(defn db-config [] (:database config))
(defn server-port [] (get-in config [:server :port]))
```

### Builder Pattern with Threading

```lisp
;; Building complex data with threading
(defn build-user [name]
  (t/->3 {:name name}
         (add-email "user@example.com")
         (add-permissions [:read :write])
         (set-active true)))

(defn add-email [user email]
  (assoc user :email email))

(defn add-permissions [user perms]
  (assoc user :permissions perms))

(defn set-active [user active]
  (assoc user :active active))
```

### Recursive Data Processing

```lisp
;; Tree traversal
(defn process-tree [tree]
  (if (leaf? tree)
    (process-leaf tree)
    (s/map-list process-tree (children tree))))

;; Accumulator pattern
(defn sum-list [lst]
  (defn sum-helper [remaining acc]
    (if (empty? remaining)
      acc
      (sum-helper (rest remaining) 
                  (+ acc (first remaining)))))
  (sum-helper lst 0))
```

## Best Practices

### Code Organization

```lisp
;; 1. Use meaningful namespaces
(ns company.project.module)

;; 2. Group related functions
(ns utils.string
  "String manipulation utilities")

(ns utils.math  
  "Mathematical operations and constants")

;; 3. Use consistent naming
(defn calculate-total [items])      ; Verb + noun
(defn valid-email? [email])         ; Predicate with ?
(def max-retry-count 3)             ; Constant with descriptive name
```

### Function Design

```lisp
;; 1. Keep functions small and focused
(defn validate-user [user]
  (and (valid-email? (:email user))
       (valid-name? (:name user))
       (valid-age? (:age user))))

;; 2. Use pure functions when possible
(defn calculate-discount [price tier]
  (* price (discount-rate tier)))

;; 3. Document complex functions
(defn complex-algorithm [data]
  "Processes data using the XYZ algorithm.
   Returns transformed data or nil if invalid."
  (when (valid-data? data)
    (apply-transformations data)))
```

### Data Structures

```lisp
;; 1. Use appropriate collection types
(def user-list '(user1 user2 user3))     ; List for sequential access
(def user-lookup {:id1 user1 :id2 user2}) ; Map for key-based access
(def user-vec [user1 user2 user3])        ; Vector for indexed access

;; 2. Use keywords for keys
{:name "John" :age 30 :active true}

;; 3. Prefer immutable updates
(defn update-user [user new-email]
  (assoc user :email new-email))  ; Returns new user, doesn't modify original
```

### Error Handling

```lisp
;; 1. Validate inputs early
(defn process-order [order]
  (assert (map? order) "Order must be a map")
  (assert (:items order) "Order must have items")
  (calculate-total (:items order)))

;; 2. Use meaningful error messages
(defn divide-safe [x y]
  (if (zero? y)
    (error "Division by zero: cannot divide" x "by" y)
    (/ x y)))

;; 3. Provide fallback values
(defn get-config-value [key default]
  (or (get config key) default))
```

### Performance Tips

```lisp
;; 1. Use appropriate sequence functions
(s/filter-list pred coll)    ; For filtering
(s/map-list fn coll)         ; For transformation
(s/reduce-list fn init coll) ; For aggregation

;; 2. Avoid deeply nested calls
;; Instead of: (f (g (h (i x))))
;; Use threading: (t/->3 x i h g f)

;; 3. Use local bindings for expensive computations
(defn expensive-calculation [x]
  (let [intermediate (complex-operation x)
        result (another-operation intermediate)]
    (finalize result)))
```

### Testing

```lisp
;; 1. Write testable functions
(defn add [x y] (+ x y))

;; 2. Use descriptive test names
(defn test-add-positive-numbers []
  (assert-eq 5 (add 2 3)))

(defn test-add-negative-numbers []
  (assert-eq -1 (add 2 -3)))

;; 3. Test edge cases
(defn test-add-zero []
  (assert-eq 5 (add 5 0))
  (assert-eq 0 (add 0 0)))
```

## Next Steps

1. **Practice in the REPL**: Start `cargo run` and experiment with the examples
2. **Read the standard library**: Explore `std/core/` modules for more functions
3. **Study the tests**: Look at files in `test/` for comprehensive examples
4. **Build projects**: Create small utilities and applications
5. **Contribute**: Add new functions to the standard library

Happy coding in Cortado! ☕️