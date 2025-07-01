mod value;
mod reader;
mod env; 
mod eval;

use reader::read;
use eval::{eval, create_default_env};

fn main() {
    let mut env = create_default_env();
    
    println!("Testing basic evaluation...");
    
    let tests = vec![
        "(+ 1 2)",
        "(defn inc [n] (+ n 1))", 
        "(inc 5)",
    ];
    
    for test in tests {
        println!(">>> {}", test);
        match read(test) {
            Ok(expr) => {
                match eval(&expr, &mut env) {
                    Ok(result) => println!("{}", result),
                    Err(e) => println!("Error: {}", e),
                }
            }
            Err(e) => println!("Parse error: {}", e),
        }
    }
    
    println!("Done!");
}