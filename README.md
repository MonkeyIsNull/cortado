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
- **Comprehensive test suite** - 382 tests covering all language features
- **Excellent performance** - Sub-second test execution

## Quick Start

### Interactive REPL

Start the interactive REPL with line editing, history, and multi-line support:

```bash
cargo run
```

### Script Execution

Run a Cortado script file:

```bash
cargo run script.lisp
cargo run -v script.lisp          # Verbose mode
```

### Expression Evaluation

Evaluate expressions directly from command line:

```bash
cargo run -- -e "(+ 1 2 3)"
cargo run -- -e "(print \"Hello, World!\")"
```

### Development Tools

Run the language demo:

```bash
cargo run demo
```

Run the comprehensive test suite:

```bash
cargo run test
```

### Help

Show usage information:

```bash
cargo run -- --help
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

### Namespaces
```lisp
; Switch to a namespace
(ns my.app)
(def config {:host "localhost" :port 8080})
(defn start-server [] (print "Server starting..."))

; Create isolated namespaces
(ns utils.math)
(defn square [x] (* x x))
(defn cube [x] (* x x x))

(ns utils.string)
(defn uppercase [s] (str-upper s))

; Access functions from other namespaces
(ns main)
(print (utils.math/square 5))     ; => 25
(print (utils.math/cube 3))       ; => 27

; Core functions are always available
(+ 1 2 3)                         ; => 6 (core/+ is accessible)
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

### Enhanced Interactive Experience

Start the REPL with modern line editing features:

```bash
$ cargo run
Cortado REPL v1.0
Welcome to Cortado - A Lisp-like programming language
Type expressions, :help for commands, or :quit to exit

cortado> (+ 1 2 3)
6
cortado> (defn factorial [n]
      ->   (if (= n 0) 1 (* n (factorial (- n 1)))))
#<function(n)>
cortado> (factorial 5)
120
cortado> :quit
Goodbye!
```

### REPL Features

- **Line editing**: Arrow keys, backspace, history navigation
- **Multi-line input**: Automatic continuation for incomplete expressions
- **Persistent history**: Saved to `~/.cortado_history`
- **REPL commands**: Type `:help` for available commands
- **Init file support**: Loads `~/.cortadorc` on startup (if exists)

### REPL Commands

```
:quit, :q          Exit REPL
:help, :h          Show help
:env               Show environment bindings  
:reload            Reload init file
:load <file>       Load and evaluate file
```

### Script Execution

Create executable scripts with shebang support:

```lisp
#!/usr/bin/env cortado

(print "Hello from Cortado script!")
(defn greet [name] (str "Hello, " name "!"))
(print (greet "World"))
```

Save as `script.lisp`, make executable, and run:

```bash
chmod +x script.lisp
./script.lisp
```

Or run directly:

```bash
cortado script.lisp              # Normal mode (only print statements show)
cortado -v script.lisp           # Verbose mode (shows all results)
```

## Test Suite

Cortado includes a comprehensive test suite with 382 individual tests covering:

- Core language features (arithmetic, variables, functions)
- Advanced constructs (closures, recursion, macros)
- Edge cases and error handling
- File I/O operations
- Mathematical functions
- Sequence operations
- Namespace isolation and resolution
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
Total Tests: 382
Passed: 382
Failed: 0
Files: 13 passed, 0 failed, 0 timeout
Total Time: 13.82s
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
- `ns` - Switch to namespace
- `require` - Load namespace modules

## Performance

Cortado is designed for efficient execution:

- **Lightweight runtime**: Minimal memory footprint and fast startup
- **Stack safe**: Efficient recursion support with overflow protection  
- **Fast evaluation**: Optimized expression parsing and evaluation
- **Interactive**: Responsive REPL with immediate feedback

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
