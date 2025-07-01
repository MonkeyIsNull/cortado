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
│   ├── core.ctl           # Core macros and functions
│   ├── math.ctl           # Mathematical functions
│   ├── seq.ctl            # Sequence operations
│   ├── str.ctl            # String operations
│   ├── map.ctl            # Map/dictionary operations
│   ├── util.ctl           # Utility functions
│   └── time.ctl           # Time-related functions
│
├── test/                   # Comprehensive test suite
│   ├── regression.ctl     # Critical functionality tests
│   ├── core-comprehensive.ctl
│   ├── math-comprehensive.ctl
│   ├── seq-comprehensive.ctl
│   ├── macro-comprehensive.ctl
│   ├── io-comprehensive.ctl
│   ├── edge-cases.ctl
│   └── ... (10+ test files, 245+ tests)
│
├── examples/               # Example Cortado programs
│   ├── simple-example.ctl
│   └── code.ctl
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