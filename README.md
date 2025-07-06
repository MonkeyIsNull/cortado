# Cortado ☕️

![Cortado Logo](logo_cortado.png)

> « Le café est une boisson qui fait dormir quand on n'en prend pas. »  
> — *Voltaire*

A Lisp-like programming language implemented in Rust. Cortado features S-expression syntax, functional programming constructs, a powerful macro system, lexical scoping, and comprehensive recursion support.


## Features

- **S-expression syntax** - Code as data philosophy
- **REPL** - Interactive Read-Eval-Print Loop
- **Functions** - First-class functions with lexical closures and recursion
- **Macros** - Code transformation with quote, quasiquote, and defmacro
- **Namespaces** - Modular code organization with aliasing support (`:as`)
- **Local bindings** - Recursive bindings with `letrec`
- **Enhanced I/O System** - Clojure-inspired polymorphic I/O with automatic resource management
- **File System Operations** - Complete file and directory manipulation capabilities
- **Comprehensive test suite** - 390+ tests covering all language features
- **Excellent performance** - Sub-second test execution

## NOTE: This is still a work in progress: ymmv

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

; Namespace aliasing with :as for shorter, more readable code
(require [core.seq :as s])
(def numbers '(1 2 3 4 5))

; Use short alias instead of full namespace
(s/map-list (fn [x] (* x 2)) numbers)     ; => (2 4 6 8 10)
(s/filter-list (fn [x] (> x 3)) numbers)  ; => (4 5)
(s/reduce-list + 0 numbers)               ; => 15
(s/length numbers)                        ; => 5
(s/reverse-list numbers)                  ; => (5 4 3 2 1)

; Multiple aliases for the same namespace work
(require [core.seq :as seq])
(seq/length numbers)                      ; => 5

; Compare: alias vs full qualification
(s/map-list inc '(1 2 3))                ; Short and clean
(core.seq/map-list inc '(1 2 3))         ; Verbose but explicit

; Aliases work with all recursive and complex functions
(s/map-list (s/length) '("a" "ab" "abc")) ; Nested aliased calls

; Core functions are always available without qualification
(+ 1 2 3)                         ; => 6 (core/+ is accessible)
```

### Enhanced I/O System

Cortado features a comprehensive, Clojure-inspired I/O system with polymorphic operations and automatic resource management:

#### Basic File Operations

```lisp
;; Enhanced file reading and writing
(spit "config.txt" "host=localhost\nport=8080")  ; Write content to file
(def config (slurp "config.txt"))                ; Read entire file
(print config)                                   ; => "host=localhost\nport=8080"

;; Legacy functions still work
(write-file "data.txt" "some data")              ; Traditional write
(def content (read-file "data.txt"))             ; Traditional read
```

#### Polymorphic Resource Operations

```lisp
;; Create readers and writers from various sources
(def file-reader (reader "input.txt"))           ; File reader
(def stdin-reader (reader :stdin))               ; Standard input reader
(def file-writer (writer "output.txt"))          ; File writer
(def stdout-writer (writer :stdout))             ; Standard output writer

;; Copy data between resources
(copy "source.txt" "destination.txt")            ; Copy files
(def bytes-copied (copy file-reader file-writer)) ; Copy between streams
```

#### File System Operations

```lisp
;; File metadata and checks
(file-exists? "myfile.txt")                      ; => true/false
(directory? "/path/to/dir")                      ; => true/false
(file-size "document.pdf")                       ; => size in bytes

;; File manipulation
(copy-file "original.txt" "backup.txt")          ; Copy files
(move-file "temp.txt" "permanent.txt")           ; Move/rename files
(delete-file "unwanted.txt")                     ; Delete files
```

#### Directory Operations

```lisp
;; Directory management
(create-dir "new-folder")                        ; Create directory
(def files (list-dir "."))                       ; List directory contents
(delete-dir "old-folder")                        ; Delete directory recursively
```

#### Enhanced Standard I/O

```lisp
;; Improved console operations
(println "Hello" "Enhanced" "I/O!")              ; => "Hello Enhanced I/O!"
(printf "User %s has %s points\n" "Alice" 150)   ; Formatted output
(def user-input (read-line))                     ; Read line from stdin
```

#### Practical I/O Examples

```lisp
;; Data processing pipeline
(spit "numbers.txt" "1\n2\n3\n4\n5")
(def numbers-text (slurp "numbers.txt"))
(println "File contains:" numbers-text)

;; Configuration management
(def app-config {:database "localhost:5432"
                 :cache-size 1000
                 :debug true})
(spit "app.config" (str app-config))

;; Backup and archiving
(when (file-exists? "important.txt")
  (copy-file "important.txt" "important.backup")
  (println "Backup created, size:" (file-size "important.backup") "bytes"))

;; Directory organization
(create-dir "processed")
(create-dir "archive")
(copy-file "data.csv" "processed/data.csv")
(move-file "old-data.csv" "archive/old-data.csv")
```

### Namespace Aliasing with `:as`

Cortado supports namespace aliasing for cleaner, more readable code:

#### Basic Aliasing Syntax
```lisp
; Basic require (loads from std/core/seq.lisp)
(require 'core.seq)
(core.seq/map-list inc '(1 2 3))           ; Verbose

; Aliased require - much cleaner!
(require [core.seq :as s])
(s/map-list inc '(1 2 3))                  ; Clean and readable
```

#### Advanced Aliasing Examples
```lisp
; Multiple aliases for organization
(require [utils.math :as math])
(require [utils.string :as str])
(require [data.processing :as dp])

; Use short, meaningful aliases
(math/square 5)                            ; => 25
(str/uppercase "hello")                    ; => "HELLO"
(dp/transform-data dataset)                ; Clean API calls

; Aliases work with complex nested calls
(s/map-list s/length '("hello" "world"))   ; => (5 5)
(s/filter-list (fn [x] (> (s/length x) 3)) strings)

; Both alias and full name work simultaneously
(require [core.seq :as s])
(require [core.seq :as seq])               ; Different alias
(s/length '(1 2 3))                        ; => 3
(seq/length '(1 2 3))                      ; => 3
(core.seq/length '(1 2 3))                 ; => 3 (still works)
```

#### Benefits of Aliasing
- **Readability**: `s/map-list` vs `core.seq/map-list`
- **Consistency**: Use familiar short names like `s`, `str`, `math`
- **Flexibility**: Multiple aliases for different contexts
- **Compatibility**: Full qualified names still work

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

; Enhanced I/O operations
(slurp "file.txt")                ; Read entire file
(spit "file.txt" "content")       ; Write content to file
(reader "input.txt")              ; Create file reader
(writer "output.txt")             ; Create file writer
(copy "src.txt" "dest.txt")       ; Copy files

; File system operations
(file-exists? "path")             ; Check if file exists
(directory? "path")               ; Check if directory
(file-size "file.txt")            ; Get file size in bytes
(copy-file "src" "dest")          ; Copy files
(move-file "old" "new")           ; Move/rename files
(delete-file "file.txt")          ; Delete file

; Directory operations
(list-dir ".")                    ; List directory contents
(create-dir "folder")             ; Create directory
(delete-dir "folder")             ; Delete directory

; Enhanced standard I/O
(read-line)                       ; Read line from stdin
(println "hello" "world")         ; Print with space separation
(printf "Hello %s\n" "World")     ; Formatted printing

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

Cortado includes a comprehensive test suite with 390 individual tests covering:

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
Total Tests: 390
Passed: 390
Failed: 0
Files: 13 passed, 0 failed, 0 timeout
Total Time: 24.45s
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
- I/O Resources: Readers, writers, input/output streams

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
- `require` - Load namespace modules (supports aliasing with `:as`)

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

## Learning Cortado

### Getting Started

New to Cortado? Start with our comprehensive programming guide:

📚 **[How to Code in Cortado](docs/HOW_TO_CODE_IN_CORTADO.md)** - Complete programming guide covering:
- Language fundamentals and syntax
- Functional programming patterns  
- Threading macros for readable code
- Namespaces and modules
- Macros and metaprogramming
- Real-world examples and best practices

### Example Programs

Explore practical examples in the `examples/` directory:

- `01-getting-started.lisp` - Beginner-friendly introduction
- `02-functional-programming.lisp` - Advanced functional patterns
- `03-data-processing.lisp` - Data transformation pipelines
- `04-threading-macros.lisp` - Readable code with `->` and `->>`
- `05-macros.lisp` - Metaprogramming and code transformation
- `06-real-world-app.lisp` - Complete task management application
- `07-advanced-topics.lisp` - Expert-level patterns and techniques
- `io-demo.lisp` - Comprehensive I/O system demonstration

Run any example:
```bash
cargo run examples/01-getting-started.lisp
```

## Project Structure

```
cortado/
├── src/           # Rust source code
├── test/          # Comprehensive test suite (.lisp files)
├── std/           # Standard library modules
├── examples/      # Example programs and tutorials
├── docs/          # Documentation and guides
└── README.md      # This file
```

## License

MIT License - see LICENSE file for details.
