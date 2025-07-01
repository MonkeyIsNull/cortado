# Cortado ☕️

> « Le café est une boisson qui fait dormir quand on n’en prend pas. »  
> — *Voltaire*

A Lisp-like programming language implemented in Rust. Cortado features S-expression syntax, functional programming constructs, a powerful macro system, and lexical scoping.

## Features

- **S-expression syntax** - Code as data philosophy
- **REPL** - Interactive Read-Eval-Print Loop
- **Functions** - First-class functions with lexical closures
- **Macros** - Code transformation with quote, quasiquote, and defmacro
- **Local bindings** - Recursive bindings with `letrec`
- **Standard library** - Written in Cortado itself, auto-loaded at startup

## Quick Start

Build and run the REPL:

```bash
cargo run
```

Run the demo:

```bash
cargo run demo
```

## Language Examples

### Basic Arithmetic
```lisp
(+ 1 2 3)          ; => 6
(* 2 3 4)          ; => 24
(/ 100 2 5)        ; => 10
```

### Variables and Functions
```lisp
(def x 42)                        ; Define variable
(defn square [n] (* n n))         ; Define function
(square 5)                        ; => 25

; Anonymous functions
(def add5 (fn [n] (+ n 5)))
(add5 10)                         ; => 15
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

### Standard Library Functions

The core library is automatically loaded and provides:

```lisp
; Arithmetic helpers
(inc 5)                           ; => 6
(dec 10)                          ; => 9
(abs -5)                          ; => 5

; Predicates
(zero? 0)                         ; => true
(pos? 5)                          ; => true
(neg? -3)                         ; => true

; Utility functions
(min 3 7)                         ; => 3
(max 3 7)                         ; => 7
(identity 42)                     ; => 42

; Control flow macros
(when true 42)                    ; => 42
(unless false 99)                 ; => 99
```

## REPL Usage

Start the REPL:

```bash
$ cargo run
Cortado REPL v1.0
Loading core library from core-simple.ctl...
"Simplified core library loaded"
Core library loaded successfully
Type expressions or 'exit' to quit

cortado> (+ 1 2 3)
6
cortado> (defn greet [name] (print "Hello," name))
#<function(name)>
cortado> (greet "World")
"Hello," "World"
cortado> exit
Goodbye!
```

The REPL supports:
- Multi-line input (continues with `...` prompt when parentheses are unbalanced)
- Automatic core library loading
- Clean output (nil results are suppressed)
- Exit with `exit` or `quit`

## Implementation Details

Cortado is implemented in Rust with the following components:

- **Reader** (`src/reader.rs`) - Tokenizes and parses S-expressions
- **Evaluator** (`src/eval.rs`) - Evaluates expressions in environments
- **Environment** (`src/env.rs`) - Lexical scoping with parent chaining
- **Values** (`src/value.rs`) - Core data types and function representations
- **Core Library** (`core-simple.ctl`) - Standard library written in Cortado

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
- `quote` / `'` - Prevent evaluation
- `quasiquote` / `` ` `` - Template with selective evaluation
- `unquote` / `~` - Evaluate within quasiquote
- `letrec` - Local recursive bindings

## Building

Requires Rust 1.70 or later:

```bash
git clone <repository>
cd cortado
cargo build --release
```

## License

MIT License - see LICENSE file for details.
