mod value;
mod reader;
mod env;
mod eval;

use reader::read;
use eval::{eval, create_default_env};

fn main() {
    let mut env = create_default_env();
    
    println!("Cortado Quick Test");
    
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
    
    println!("Done!");
}