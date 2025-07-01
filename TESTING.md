# Cortado Testing Guide

## 🧪 Comprehensive Test Suite

This test suite ensures Cortado's functionality remains stable during development. The tests cover all major language features and edge cases.

## 📁 Test Files

### Core Language Tests
- **`test/core-comprehensive.ctl`** - Tests all fundamental language features
  - Basic data types (numbers, strings, booleans, nil, keywords)
  - Arithmetic operations (+, -, *, /)
  - Comparison operations (=, not=, <, >)
  - Variable definitions and scoping
  - Function definitions (defn, fn)
  - Conditional expressions (if)
  - List operations (first, rest, cons)
  - Boolean logic (not)
  - Lexical scoping and closures
  - Letrec bindings
  - String operations

### Math Module Tests  
- **`test/math-comprehensive.ctl`** - Tests all math functions
  - Arithmetic helpers (inc, dec)
  - Absolute value (abs)
  - Min/max functions
  - Math predicates (zero?, pos?, neg?)
  - Square and cube functions
  - Combined operations and edge cases
  - Mathematical identities and properties

### Sequence Operations Tests
- **`test/seq-comprehensive.ctl`** - Tests sequence functions
  - List creation and basic operations
  - Map, filter, reduce operations (when available)
  - Take, drop, range functions
  - Count and nth operations
  - Manual implementations for testing
  - Complex sequence operations

### Macro System Tests
- **`test/macro-comprehensive.ctl`** - Tests macro functionality
  - Basic quoting with quote and '
  - Quasiquoting with ` and unquote with ~
  - Simple macro definitions
  - Standard library macros (when, unless)
  - Macro expansion with macroexpand
  - Complex macro scenarios
  - Macro hygiene and scoping

### File I/O Tests
- **`test/io-comprehensive.ctl`** - Tests file operations
  - String operations (str, str-length)
  - File write/read operations
  - Time operations (now-ms, sleep-ms)
  - Complex I/O scenarios
  - Timing utilities
  - Load function tests
  - Integration and performance tests

### Edge Cases and Error Handling
- **`test/edge-cases.ctl`** - Tests boundary conditions
  - Empty and nil handling
  - Numeric edge cases (zero, negative, large numbers)
  - String edge cases (empty strings, type conversion)
  - List edge cases (empty, single element, nested)
  - Function edge cases (no params, returning functions)
  - Conditional edge cases (truthiness)
  - Comparison edge cases (different types)
  - Variable scoping edge cases
  - Performance edge cases

### Regression Tests
- **`test/regression.ctl`** - Critical functionality tests
  - Essential arithmetic operations
  - Core comparisons and variables
  - Basic functions and conditionals
  - Critical list operations
  - File I/O and time functions
  - Executable test that verifies core functionality

## 🚀 Running Tests

### Command Line
```bash
# Run all tests
cargo run test

# Run just the demo
cargo run demo

# Start REPL
cargo run
```

### From REPL
```lisp
; Run test suite
(run-tests)

; Load specific test file
(load "test/regression.ctl")
```

### Individual Test Files
```bash
# Load specific test manually
echo '(load "test/regression.ctl")' | cargo run
```

## ✅ Test Categories

### 1. **Smoke Tests** - Basic functionality must work
- Arithmetic: `(+ 1 2)` → `3`
- Variables: `(def x 5)` then `x` → `5`
- Functions: `(defn f [x] x)` then `(f 42)` → `42`

### 2. **Feature Tests** - All language features
- Data types, operators, control flow
- Function definitions and calls
- Macro system and code generation
- File I/O and string operations

### 3. **Integration Tests** - Features working together
- Complex expressions combining multiple features
- Standard library loading and usage
- File operations with computed content

### 4. **Edge Case Tests** - Boundary conditions
- Empty inputs, nil values, zero operations
- Large numbers, nested structures
- Error conditions and recovery

### 5. **Regression Tests** - Critical paths
- Core functionality that must never break
- Essential operations for language usability
- Quick verification of basic features

## 🔧 Test Utilities

### Assert Functions
```lisp
; Compare expected vs actual
(assert-eq expected actual)

; Test output shows PASS/FAIL
"PASS:" 42 "==" 42
"FAIL: expected 5 but got 6"
```

### Test Runner
```lisp
; Native function that scans test/ directory
(run-tests)
```

## 📊 Test Status

Current test suite includes:
- **200+ individual test cases**
- **9 comprehensive test files** 
- **Full language coverage**
- **Edge case validation**
- **Regression protection**

## 🎯 Adding New Tests

When adding new features:

1. **Add feature tests** to appropriate comprehensive file
2. **Add edge cases** to `edge-cases.ctl`
3. **Add critical functionality** to `regression.ctl`
4. **Test both success and failure cases**
5. **Verify test passes**: `cargo run test`

## 🐛 Debugging Failed Tests

1. **Run individual test file**: `(load "test/specific.ctl")`
2. **Check FAIL messages** for expected vs actual values
3. **Test isolated functionality** in REPL
4. **Add debug prints** to narrow down issues

The test suite ensures Cortado remains stable and functional as development continues!