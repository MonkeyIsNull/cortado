mod value;
mod reader;
mod env;
mod eval;

use reader::read;
use eval::{eval, create_default_env};
use env::Env;
use std::io::{self, Write};

fn load_core_library(env: &mut Env) -> Result<(), String> {
    use std::fs;
    
    let core_path = "core-simple.ctl";
    match fs::read_to_string(core_path) {
        Ok(content) => {
            println!("Loading core library from {}...", core_path);
            
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
                                    println!("Error loading core: {}", e);
                                    return Err(e);
                                }
                            }
                        }
                        Err(e) => {
                            println!("Parse error in core: {}", e);
                            return Err(e);
                        }
                    }
                    current_expr.clear();
                }
            }
            
            println!("Core library loaded successfully");
            Ok(())
        }
        Err(_) => {
            println!("No {} found, starting without core library", core_path);
            Ok(())
        }
    }
}

fn repl() {
    let mut env = create_default_env();
    
    // Startup hook - automatically load core library
    println!("Cortado REPL v1.0");
    if let Err(e) = load_core_library(&mut env) {
        println!("Warning: Failed to load core library: {}", e);
    }
    
    println!("Type expressions or 'exit' to quit\n");
    
    loop {
        print!("cortado> ");
        io::stdout().flush().unwrap();
        
        let mut input = String::new();
        match io::stdin().read_line(&mut input) {
            Ok(_) => {
                let input = input.trim();
                
                if input.is_empty() {
                    continue;
                }
                
                if input == "exit" || input == "quit" {
                    println!("Goodbye!");
                    break;
                }
                
                // Handle multi-line input by checking parentheses balance
                let mut complete_expr = input.to_string();
                let mut paren_count = 0;
                
                for ch in input.chars() {
                    match ch {
                        '(' => paren_count += 1,
                        ')' => paren_count -= 1,
                        _ => {}
                    }
                }
                
                // If parentheses aren't balanced, continue reading
                while paren_count > 0 {
                    print!("... ");
                    io::stdout().flush().unwrap();
                    
                    let mut continuation = String::new();
                    match io::stdin().read_line(&mut continuation) {
                        Ok(_) => {
                            complete_expr.push(' ');
                            complete_expr.push_str(continuation.trim());
                            
                            for ch in continuation.chars() {
                                match ch {
                                    '(' => paren_count += 1,
                                    ')' => paren_count -= 1,
                                    _ => {}
                                }
                            }
                        }
                        Err(e) => {
                            println!("Error reading input: {}", e);
                            break;
                        }
                    }
                }
                
                // Evaluate the complete expression
                match read(&complete_expr) {
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

fn main() {
    let args: Vec<String> = std::env::args().collect();
    
    if args.len() > 1 && args[1] == "demo" {
        run_demo();
    } else {
        repl();
    }
}
