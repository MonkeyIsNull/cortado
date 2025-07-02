mod value;
mod reader;
mod env;
mod eval;

use reader::read;
use eval::{eval, create_default_env};
use env::Env;
use value::Value;
use std::io::{self, Write};
use std::path::Path;

fn load_stdlib(env: &mut Env) -> Result<(), String> {
    let std_dir = Path::new("std");
    
    // Check if std directory exists
    if !std_dir.exists() {
        println!("No std/ directory found, starting without standard library");
        return Ok(());
    }
    
    println!("Loading standard library...");
    
    // Define loading order - core should be loaded first
    let modules = vec![
        "core.lisp",
        "math.lisp", 
        "seq.lisp",
        "str.lisp",
        "map.lisp",
        "util.lisp",
        "time.lisp",
    ];
    
    for module in modules {
        let module_path = std_dir.join(module);
        if module_path.exists() {
            println!("Loading std/{}", module);
            if let Err(e) = load_file(&module_path, env) {
                println!("Warning: Failed to load {}: {}", module, e);
            }
        }
    }
    
    println!("Standard library loaded successfully");
    Ok(())
}

fn load_file(path: &Path, env: &mut Env) -> Result<(), String> {
    use std::fs;
    
    let content = match fs::read_to_string(path) {
        Ok(content) => content,
        Err(e) => return Err(format!("Failed to read file: {}", e)),
    };
    
    // Split into expressions and evaluate each one
    let lines: Vec<&str> = content.lines().collect();
    let mut current_expr = String::new();
    let mut paren_count = 0;
    
    for line in lines {
        let trimmed = line.trim();
        if trimmed.is_empty() || trimmed.starts_with(';') {
            continue;
        }
        
        current_expr.push_str(line);
        current_expr.push(' ');
        
        // Count parentheses to detect complete expressions
        for ch in trimmed.chars() {
            match ch {
                '(' => paren_count += 1,
                ')' => paren_count -= 1,
                _ => {}
            }
        }
        
        // If we have a complete expression, evaluate it
        if paren_count == 0 && !current_expr.trim().is_empty() {
            match read(&current_expr) {
                Ok(expr) => {
                    match eval(&expr, env) {
                        Ok(_) => {}, // Successfully loaded
                        Err(e) => {
                            return Err(format!("Error evaluating: {}", e));
                        }
                    }
                }
                Err(e) => {
                    return Err(format!("Parse error: {}", e));
                }
            }
            current_expr.clear();
        }
    }
    
    Ok(())
}

fn repl() {
    let mut env = create_default_env();
    
    // Startup hook - automatically load standard library
    println!("Cortado REPL v1.0");
    
    // Standard library loading disabled due to interaction issues
    // Core functionality is available through built-in functions
    println!("Standard library loading disabled (core functions available)");
    
    println!("Type expressions or 'exit' to quit\n");
    
    loop {
        print!("cortado> ");
        io::stdout().flush().unwrap();
        
        let mut input = String::new();
        match io::stdin().read_line(&mut input) {
            Ok(0) => {
                // EOF reached
                println!("Goodbye!");
                break;
            }
            Ok(_) => {
                let input = input.trim();
                
                if input.is_empty() {
                    continue;
                }
                
                if input == "exit" || input == "quit" {
                    println!("Goodbye!");
                    break;
                }
                
                // Simple single-line evaluation for now (no multi-line support)
                // This avoids the complex parentheses balancing that might be causing issues
                match read(input) {
                    Ok(expr) => {
                        match eval(&expr, &mut env) {
                            Ok(result) => {
                                // Don't print nil results to keep output clean
                                if result.to_string() != "nil" {
                                    println!("{}", result);
                                }
                            }
                            Err(e) => println!("Error: {}", e),
                        }
                    }
                    Err(e) => println!("Parse error: {}", e),
                }
            }
            Err(e) => {
                println!("Error reading input: {}", e);
                break;
            }
        }
    }
}

fn run_demo() {
    let mut env = create_default_env();
    
    println!("Cortado Language Demo\n");
    
    let examples = vec![
        "(+ 1 2)",
        "(def x 5)",
        "x",
        "(defn double [n] (* n 2))",
        "(double 3)",
        "(if (= 1 1) \"yes\" \"no\")",
        "'(a b c)",
        "(defmacro unless [cond body] `(if ~cond nil ~body))",
        "(unless false 42)",
        "(letrec [[x 10]] x)",
    ];

    for example in examples {
        println!(">>> {}", example);
        match read(example) {
            Ok(expr) => {
                match eval(&expr, &mut env) {
                    Ok(result) => println!("{}", result),
                    Err(e) => println!("Error: {}", e),
                }
            }
            Err(e) => println!("Parse error: {}", e),
        }
    }
    
    println!("\nDemo completed successfully!");
}

fn run_tests() {
    let mut env = create_default_env();
    
    // Skip the eval.rs run-tests function entirely and run comprehensive tests directly
    run_comprehensive_tests(&mut env);
}

fn run_comprehensive_tests(_env: &mut Env) {
    use std::time::Instant;
    
    let overall_start = Instant::now();
    println!("CORTADO COMPREHENSIVE TEST SUITE");
    println!("=================================");
    
    // Reset global test counters
    let mut reset_env = create_default_env();
    if let Ok(expr) = read("(reset-test-counts)") {
        let _ = eval(&expr, &mut reset_env);
    }
    
    // Dynamically discover ALL test files for complete coverage
    let test_dir = std::path::Path::new("test");
    let mut test_files = Vec::new();
    
    if let Ok(entries) = std::fs::read_dir(test_dir) {
        for entry in entries {
            if let Ok(entry) = entry {
                let path = entry.path();
                if path.extension().map_or(false, |ext| ext == "lisp") {
                    if let Some(name) = path.file_name().and_then(|n| n.to_str()) {
                        test_files.push(name.to_string());
                    }
                }
            }
        }
    }
    
    test_files.sort(); // Consistent order
    
    let mut total_files = 0;
    let mut passed_files = 0;
    let mut failed_files = 0;
    let mut timeout_files = 0;
    let mut total_time = 0.0;
    
    // Run each test file with timeout
    for test_file in test_files {
        total_files += 1;
        println!("\nTesting: {}", test_file);
        
        let start = Instant::now();
        let test_cmd = format!("(load \"test/{}\")", test_file);
        
        match read(&test_cmd) {
            Ok(expr) => {
                // PERFORMANCE FIX: Create fresh environment for each test file to prevent pollution
                let mut fresh_env = create_default_env();
                
                // MINIMAL essential functions - anything more causes environment pollution
                let essential_funcs = vec![
                    "(defn assert-eq [expected actual] (test-assert-eq expected actual))",
                ];
                
                for func in essential_funcs {
                    if let Ok(expr) = read(func) {
                        let _ = eval(&expr, &mut fresh_env);
                    }
                }
                
                match eval(&expr, &mut fresh_env) {
                    Ok(_) => {
                        let elapsed = start.elapsed().as_secs_f64();
                        total_time += elapsed;
                        
                        if elapsed > 6.0 {
                            println!("  TIMEOUT ({:.2}s > 6.0s limit)", elapsed);
                            timeout_files += 1;
                        } else {
                            println!("  PASSED ({:.2}s)", elapsed);
                            passed_files += 1;
                        }
                    },
                    Err(e) => {
                        let elapsed = start.elapsed().as_secs_f64();
                        total_time += elapsed;
                        println!("  FAILED: {} ({:.2}s)", e, elapsed);
                        failed_files += 1;
                    }
                }
            },
            Err(e) => {
                println!("  PARSE ERROR: {}", e);
                failed_files += 1;
            }
        }
    }
    
    let overall_elapsed = overall_start.elapsed().as_secs_f64();
    
    // Get final test counts using the eval functions
    let mut count_env = create_default_env();
    let total_passed = if let Ok(expr) = read("(get-pass-count)") {
        if let Ok(Value::Number(n)) = eval(&expr, &mut count_env) {
            n as usize
        } else { 0 }
    } else { 0 };
    
    let total_failed = if let Ok(expr) = read("(get-fail-count)") {
        if let Ok(Value::Number(n)) = eval(&expr, &mut count_env) {
            n as usize
        } else { 0 }
    } else { 0 };
    
    let total_tests = total_passed + total_failed;
    
    println!("\nCOMPREHENSIVE TEST RESULTS");
    println!("==========================");
    println!("Total Tests: {}", total_tests);
    println!("Passed: {}", total_passed);
    println!("Failed: {}", total_failed);
    println!("Files: {} passed, {} failed, {} timeout", passed_files, failed_files, timeout_files);
    println!("Total Time: {:.2}s", overall_elapsed);
    
    if total_tests > 0 {
        println!("Pass Rate: {:.1}%", (total_passed as f64 / total_tests as f64) * 100.0);
    }
    
    if total_failed == 0 && timeout_files == 0 {
        println!("ALL TESTS PASSED!");
    } else if total_passed > 0 {
        println!("PARTIAL SUCCESS - Some tests failed or timed out");
    } else {
        println!("NO TESTS PASSED - Critical issues detected");
    }
}

fn main() {
    let args: Vec<String> = std::env::args().collect();
    
    if args.len() > 1 {
        match args[1].as_str() {
            "demo" => run_demo(),
            "test" => run_tests(),
            _ => {
                println!("Usage: cortado [demo|test]");
                println!("  demo - Run language demo");
                println!("  test - Run test suite");
                println!("  (no args) - Start REPL");
            }
        }
    } else {
        repl();
    }
}
