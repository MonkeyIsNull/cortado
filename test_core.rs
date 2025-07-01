// Minimal test for core library
mod value;
mod reader;
mod env;
mod eval;

use reader::read;
use eval::{eval, create_default_env};
use env::Env;

fn main() {
    let mut env = create_default_env();
    
    println!("Testing basic core library function...");
    
    // Test simple function
    let test = "(defn inc [n] (+ n 1))";
    println!(">>> {}", test);
    match read(test) {
        Ok(expr) => {
            match eval(&expr, &mut env) {
                Ok(result) => println!("Result: {}", result),
                Err(e) => println!("Error: {}", e),
            }
        }
        Err(e) => println!("Parse error: {}", e),
    }
    
    // Test calling the function
    let test2 = "(inc 5)";
    println!(">>> {}", test2);
    match read(test2) {
        Ok(expr) => {
            match eval(&expr, &mut env) {
                Ok(result) => println!("Result: {}", result),
                Err(e) => println!("Error: {}", e),
            }
        }
        Err(e) => println!("Parse error: {}", e),
    }
    
    println!("Test completed");
}