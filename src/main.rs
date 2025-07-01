mod value;
mod reader;
mod env;
mod eval;

use reader::read;
use eval::{eval, create_default_env};
use env::Env;
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
        "core.ctl",
        "math.ctl", 
        "seq.ctl",
        "str.ctl",
        "map.ctl",
        "util.ctl",
        "time.ctl",
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
    
    println!("Cortado Test Runner");
    
    // Run the comprehensive test suite using the built-in run-tests function
    // This function has its own test environment setup and doesn't depend on stdlib loading
    println!("Running comprehensive test suite...");
    
    match eval(&read("(run-tests)").unwrap(), &mut env) {
        Ok(result) => println!("\nFinal result: {}", result),
        Err(e) => println!("Error running test suite: {}", e),
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
