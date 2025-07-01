# Cortado Project Structure

```
cortado/
├── src/                    # Rust source code
│   ├── main.rs            # Main entry point (REPL, demo, test runner)
│   ├── value.rs           # Value types and data structures
│   ├── reader.rs          # S-expression parser
│   ├── eval.rs            # Evaluator and built-in functions
│   └── env.rs             # Environment (variable scoping)
│
├── std/                    # Standard library (written in Cortado)
│   ├── core.lisp          # Core macros and functions
│   ├── math.lisp          # Mathematical functions
│   ├── seq.lisp           # Sequence operations
│   ├── str.lisp           # String operations
│   ├── map.lisp           # Map/dictionary operations
│   ├── util.lisp          # Utility functions
│   └── time.lisp          # Time-related functions
│
├── test/                   # Comprehensive test suite
│   ├── regression.lisp    # Critical functionality tests
│   ├── core-comprehensive.lisp
│   ├── math-comprehensive.lisp
│   ├── seq-comprehensive.lisp
│   ├── macro-comprehensive.lisp
│   ├── io-comprehensive.lisp
│   ├── edge-cases.lisp
│   └── ... (10+ test files, 245+ tests)
│
├── examples/               # Example Cortado programs
│   ├── simple-example.lisp
│   └── code.lisp
│
├── docs/                   # Documentation
│   ├── COMPREHENSIVE_TEST_SUMMARY.md
│   ├── RECURSION_AND_TCO_SUMMARY.md
│   └── TESTING.md
│
├── Cargo.toml             # Rust package configuration
├── README.md              # Project overview and quick start
└── .gitignore             # Git ignore rules
```

## Directory Purposes

- **src/**: Core interpreter implementation in Rust
- **std/**: Standard library modules written in Cortado itself
- **test/**: Comprehensive test suite with 245+ tests
- **examples/**: Example programs demonstrating language features
- **docs/**: Detailed documentation about implementation and testing