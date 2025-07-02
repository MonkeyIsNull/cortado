# Cortado ☕️

> « Le café est une boisson qui fait dormir quand on n'en prend pas. »  
> — *Voltaire*

A Lisp-like programming language implemented in Rust. Cortado features S-expression syntax, functional programming constructs, a powerful macro system, lexical scoping, and comprehensive recursion support.

## Features

- **S-expression syntax** - Code as data philosophy
- **REPL** - Interactive Read-Eval-Print Loop
- **Functions** - First-class functions with lexical closures and recursion
- **Macros** - Code transformation with quote, quasiquote, and defmacro
- **Local bindings** - Recursive bindings with `letrec`
- **Comprehensive test suite** - 366 tests covering all language features
- **Excellent performance** - Sub-second test execution

## Quick Start

Build and run the REPL:

```bash
cargo run
```

Run the demo:

```bash
cargo run demo
```

Run the comprehensive test suite:

```bash
cargo run test
```

## Language Examples

### Basic Arithmetic
```lisp
(+ 1 2 3)          ; => 6
(* 2 3 4)          ; => 24
(/ 100 2 5)        ; => 10
(% 10 3)           ; => 1
```

### Variables and Functions
```lisp
(def x 42)                        ; Define variable
(defn square [n] (* n n))         ; Define function
(square 5)                        ; => 25

; Anonymous functions
(def add5 (fn [n] (+ n 5)))
(add5 10)                         ; => 15

; Recursive functions
(defn factorial [n]
  (if (= n 0) 1 (* n (factorial (- n 1)))))
(factorial 5)                     ; => 120
```

### Closures and Higher-Order Functions
```lisp
(def make-adder (fn [x] (fn [y] (+ x y))))
(def add10 (make-adder 10))
(add10 5)                         ; => 15
```

### Conditionals
```lisp
(if (= 1 1) "equal" "not equal")  ; => "equal"
(if (> 5 3) "yes" "no")           ; => "yes"
```

### Macros
```lisp
; Define a macro
(defmacro unless [cond body] 
  `(if ~cond nil ~body))

; Use the macro
(unless false (print "This will print"))

; Macro expansion
(macroexpand '(unless false 42))  ; => (if false nil 42)
```

### Quoting and Code Manipulation
```lisp
'(a b c)                          ; => (a b c)
(quote (+ 1 2))                   ; => (+ 1 2)
`(list 1 2 ~(+ 1 2))             ; => (list 1 2 3)
```

### Local Recursive Bindings
```lisp
; Simple local binding
(letrec [[x 42]] x)               ; => 42

; Multiple bindings
(letrec [[double (fn [x] (* x 2))]
         [triple (fn [x] (* x 3))]]
  (+ (double 5) (triple 4)))      ; => 22
```

### Built-in Functions

Core arithmetic and utility functions:

```lisp
; Arithmetic helpers
(inc 5)                           ; => 6
(dec 10)                          ; => 9
(abs -5)                          ; => 5

; Predicates
(zero? 0)                         ; => true
(pos? 5)                          ; => true
(neg? -3)                         ; => true
(even? 4)                         ; => true
(odd? 3)                          ; => true

; Utility functions
(min 3 7)                         ; => 3
(max 3 7)                         ; => 7
(identity 42)                     ; => 42

; Control flow macros
(when true 42)                    ; => 42
(unless false 99)                 ; => 99

; Math functions
(square 4)                        ; => 16
(cube 3)                          ; => 27

; String operations
(str "Hello " "World")            ; => "Hello World"
(str-len "hello")                 ; => 5

; Time functions
(time (+ 1 2))                    ; Times execution
(now)                             ; Current timestamp
```

## REPL Usage

Start the REPL:

```bash
$ cargo run
Cortado REPL v1.0
Standard library loading disabled (core functions available)
Type expressions or 'exit' to quit

cortado> (+ 1 2 3)
6
cortado> (defn greet [name] (str "Hello, " name "!"))
#<function(name)>
cortado> (greet "World")
"Hello, World!"
cortado> exit
Goodbye!
```

The REPL supports:
- Single-line expression evaluation
- Built-in functions (no external library loading needed)
- Clean output (nil results are suppressed)
- Exit with `exit` or `quit`

## Test Suite

Cortado includes a comprehensive test suite with 366 individual tests covering:

- Core language features (arithmetic, variables, functions)
- Advanced constructs (closures, recursion, macros)
- Edge cases and error handling
- File I/O operations
- Mathematical functions
- Sequence operations
- Performance edge cases

Run the test suite:

```bash
$ cargo run test
CORTADO COMPREHENSIVE TEST SUITE
=================================

Testing: core-comprehensive.lisp
  PASSED (0.15s)

Testing: macro-comprehensive.lisp  
  PASSED (4.51s)

... (11 test files) ...

COMPREHENSIVE TEST RESULTS
==========================
Total Tests: 366
Passed: 366
Failed: 0
Files: 11 passed, 0 failed, 0 timeout
Total Time: 11.00s
Pass Rate: 100.0%
ALL TESTS PASSED!
```

## Implementation Details

Cortado is implemented in Rust with the following components:

- **Reader** (`src/reader.rs`) - Tokenizes and parses S-expressions
- **Evaluator** (`src/eval.rs`) - Evaluates expressions with built-in functions
- **Environment** (`src/env.rs`) - Lexical scoping with parent chaining
- **Values** (`src/value.rs`) - Core data types and function representations

### Value Types

- Numbers: `42`, `3.14`
- Strings: `"hello"`
- Symbols: `x`, `my-var`
- Keywords: `:keyword`
- Booleans: `true`, `false`
- Nil: `nil`
- Lists: `(1 2 3)`
- Vectors: `[1 2 3]`
- Maps: `{:a 1 :b 2}`
- Functions: Native and user-defined
- Macros: Code transformation functions

### Special Forms

- `def` - Define variables
- `fn` - Create anonymous functions
- `defn` - Define named functions
- `defmacro` - Define macros
- `if` - Conditional expression
- `do` - Execute multiple expressions
- `quote` / `'` - Prevent evaluation
- `quasiquote` / `` ` `` - Template with selective evaluation
- `unquote` / `~` - Evaluate within quasiquote
- `letrec` - Local recursive bindings
- `load` - Load and evaluate files
- `macroexpand` - Expand macro calls

## Performance

Cortado is optimized for performance:

- Fresh environments per test file prevent memory pollution
- Efficient recursion support without stack overflow
- Sub-second execution for comprehensive test suite
- Minimal memory footprint during evaluation

## Building

Requires Rust 1.70 or later:

```bash
git clone https://github.com/MonkeyIsNull/cortado 
cd cortado  
cargo build --release
```

## Project Structure

```
cortado/
├── src/           # Rust source code
├── test/          # Comprehensive test suite (.lisp files)
├── std/           # Standard library modules
├── examples/      # Example programs
├── docs/          # Documentation
└── README.md      # This file
```

## License

MIT License - see LICENSE file for details.
