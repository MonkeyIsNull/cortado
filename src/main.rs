mod value;
mod reader;
mod env;
mod eval;

use reader::read;
use eval::{eval, create_default_env};

fn main() {
    let mut env = create_default_env();
    
    let examples = vec![
        "(def x 5)",
        "x",
        "(+ x 10)",
        "(def double (fn [n] (* n 2)))",
        "(double 5)",
        "(double x)",
        "(defn add3 [a b c] (+ a b c))",
        "(add3 1 2 3)",
        "(defn factorial [n] (if (= n 0) 1 (* n (factorial (- n 1)))))",
        "(factorial 5)",
        "(if (= 1 1) \"equal\" \"not equal\")",
        "(if false \"yes\" \"no\")",
        "(print \"Hello\" \"World!\")",
        "(* 2 3 4)",
        "(/ 100 2 5)",
        "(not= 1 2)",
        "(= 1 1 1)",
    ];

    println!("Cortado Evaluator Demo\n");
    
    for example in examples {
        println!(">>> {}", example);
        match read(example) {
            Ok(expr) => {
                match eval(&expr, &mut env) {
                    Ok(result) => println!("{}", result),
                    Err(e) => println!("Eval error: {}", e),
                }
            }
            Err(e) => println!("Parse error: {}", e),
        }
        println!();
    }
    
    println!("\nUser-defined function examples:");
    
    let custom_examples = vec![
        "(defn greet [name] (print \"Hello,\" name))",
        "(greet \"Alice\")",
        "(def make-adder (fn [x] (fn [y] (+ x y))))",
        "(def add5 (make-adder 5))",
        "(add5 10)",
    ];
    
    for example in custom_examples {
        println!(">>> {}", example);
        match read(example) {
            Ok(expr) => {
                match eval(&expr, &mut env) {
                    Ok(result) => println!("{}", result),
                    Err(e) => println!("Eval error: {}", e),
                }
            }
            Err(e) => println!("Parse error: {}", e),
        }
        println!();
    }
    
    println!("\nMacro examples:");
    
    let macro_examples = vec![
        "'(+ 1 2)",  // Quote example
        "(quote (a b c))",  // Quote example
        "`(list 1 2 ~(+ 1 2))",  // Quasiquote with unquote
        "(defmacro unless [cond body] `(if ~cond nil ~body))",
        "(macroexpand '(unless false (print \"hi\")))",
        "(unless false (print \"This should print\"))",
        "(unless true (print \"This should not print\"))",
        "(defmacro when [cond body] `(if ~cond ~body nil))",
        "(when true (print \"This prints with when\"))",
        "(defmacro infix [a op b] `(~op ~a ~b))",
        "(macroexpand '(infix 2 + 3))",
        "(infix 2 + 3)",
    ];
    
    for example in macro_examples {
        println!(">>> {}", example);
        match read(example) {
            Ok(expr) => {
                match eval(&expr, &mut env) {
                    Ok(result) => println!("{}", result),
                    Err(e) => println!("Eval error: {}", e),
                }
            }
            Err(e) => println!("Parse error: {}", e),
        }
        println!();
    }
}
