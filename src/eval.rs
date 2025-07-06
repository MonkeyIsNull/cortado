use crate::env::Env;
use crate::value::{Value, Function, IOResource};
use std::collections::HashMap;
use std::cell::RefCell;
use std::sync::{Arc, Mutex};
use std::io::{BufRead, Write, Read};

pub fn eval(expr: &Value, env: &mut Env) -> Result<Value, String> {
    match expr {
        Value::Number(_) | Value::Bool(_) | Value::Nil | Value::Str(_) | Value::Keyword(_) | Value::IOResource(_) => {
            Ok(expr.clone())
        }
        Value::Uninitialized => {
            Err("Cannot evaluate uninitialized value".to_string())
        }
        Value::Symbol(name) => env
            .get(name)
            .or_else(|| env.get_with_aliases(name))
            .ok_or_else(|| format!("Undefined symbol: {}", name)),
        Value::Vector(items) => {
            let mut result = Vec::new();
            for item in items {
                result.push(eval(item, env)?);
            }
            Ok(Value::Vector(result))
        }
        Value::Map(map) => {
            let mut result = HashMap::new();
            for (k, v) in map {
                result.insert(k.clone(), eval(v, env)?);
            }
            Ok(Value::Map(result))
        }
        Value::List(list) => {
            if list.is_empty() {
                return Ok(Value::List(vec![]));
            }

            if let Value::Symbol(name) = &list[0] {
                match name.as_str() {
                    "def" => eval_def(list, env),
                    "defn" => eval_defn(list, env),
                    "defmacro" => eval_defmacro(list, env),
                    "if" => eval_if(list, env),
                    "fn" => eval_fn(list, env),
                    "quote" => eval_quote(list),
                    "quasiquote" => eval_quasiquote(list, env),
                    "macroexpand" => eval_macroexpand(list, env),
                    "letrec" => eval_letrec(list, env),
                    "let" => eval_let(list, env), // let handles Clojure-style flat vector syntax
                    "load" => eval_load(list, env),
                    "do" => eval_do(list, env),
                    "ns" => eval_ns(list, env),
                    "require" => eval_require(list, env),
                    "and" => eval_and(list, env),
                    "or" => eval_or(list, env),
                    _ => eval_call(list, env),
                }
            } else {
                eval_call(list, env)
            }
        }
        Value::Function(_) => Ok(expr.clone()),
    }
}

fn eval_def(list: &[Value], env: &mut Env) -> Result<Value, String> {
    if list.len() != 3 {
        return Err("def requires exactly 2 arguments".to_string());
    }

    if let Value::Symbol(name) = &list[1] {
        let value = eval(&list[2], env)?;
        env.set_namespaced(name.clone(), value.clone());
        Ok(value)
    } else {
        Err("First argument to def must be a symbol".to_string())
    }
}

fn eval_if(list: &[Value], env: &mut Env) -> Result<Value, String> {
    if list.len() != 4 {
        return Err("if requires exactly 3 arguments".to_string());
    }

    let condition = eval(&list[1], env)?;
    let is_truthy = match condition {
        Value::Bool(false) | Value::Nil => false,
        _ => true,
    };

    if is_truthy {
        eval(&list[2], env)
    } else {
        eval(&list[3], env)
    }
}

fn eval_do(list: &[Value], env: &mut Env) -> Result<Value, String> {
    if list.len() < 2 {
        return Err("do requires at least 1 argument".to_string());
    }

    let mut last_result = Value::Nil;
    for expr in &list[1..] {
        last_result = eval(expr, env)?;
    }
    Ok(last_result)
}

fn eval_and(list: &[Value], env: &mut Env) -> Result<Value, String> {
    // (and) returns true
    if list.len() == 1 {
        return Ok(Value::Bool(true));
    }
    
    // Short-circuit evaluation: return first falsy value or last value
    for expr in &list[1..] {
        let result = eval(expr, env)?;
        match result {
            Value::Bool(false) | Value::Nil => return Ok(result),
            _ => {
                // If this is the last expression, return its value
                if expr == list.last().unwrap() {
                    return Ok(result);
                }
                // Otherwise continue to next expression
            }
        }
    }
    
    // Should not reach here, but return true as fallback
    Ok(Value::Bool(true))
}

fn eval_or(list: &[Value], env: &mut Env) -> Result<Value, String> {
    // (or) returns nil  
    if list.len() == 1 {
        return Ok(Value::Nil);
    }
    
    // Short-circuit evaluation: return first truthy value or last value
    for expr in &list[1..] {
        let result = eval(expr, env)?;
        match result {
            Value::Bool(false) | Value::Nil => {
                // If this is the last expression, return its value
                if expr == list.last().unwrap() {
                    return Ok(result);
                }
                // Otherwise continue to next expression  
            }
            _ => return Ok(result), // Return first truthy value
        }
    }
    
    // Should not reach here, but return nil as fallback
    Ok(Value::Nil)
}

fn eval_defn(list: &[Value], env: &mut Env) -> Result<Value, String> {
    if list.len() != 4 {
        return Err("defn requires exactly 3 arguments".to_string());
    }

    if let Value::Symbol(name) = &list[1] {
        // Simple approach: define the function normally
        // Self-recursion is handled in eval_call by adding function to environment during calls
        let fn_value = eval_fn(&[
            Value::Symbol("fn".to_string()),
            list[2].clone(),
            list[3].clone(),
        ], env)?;
        
        env.set_namespaced(name.clone(), fn_value.clone());
        Ok(fn_value)
    } else {
        Err("First argument to defn must be a symbol".to_string())
    }
}

fn eval_quote(list: &[Value]) -> Result<Value, String> {
    if list.len() != 2 {
        return Err("quote requires exactly 1 argument".to_string());
    }
    Ok(list[1].clone())
}

fn eval_quasiquote(list: &[Value], env: &mut Env) -> Result<Value, String> {
    if list.len() != 2 {
        return Err("quasiquote requires exactly 1 argument".to_string());
    }
    eval_quasiquote_form(&list[1], env)
}

fn eval_quasiquote_form(form: &Value, env: &mut Env) -> Result<Value, String> {
    match form {
        Value::List(items) => {
            if !items.is_empty() {
                if let Value::Symbol(sym) = &items[0] {
                    if sym == "unquote" {
                        if items.len() != 2 {
                            return Err("unquote requires exactly 1 argument".to_string());
                        }
                        return eval(&items[1], env);
                    }
                }
            }
            
            let mut result = Vec::new();
            for item in items {
                result.push(eval_quasiquote_form(item, env)?);
            }
            Ok(Value::List(result))
        }
        Value::Vector(items) => {
            let mut result = Vec::new();
            for item in items {
                result.push(eval_quasiquote_form(item, env)?);
            }
            Ok(Value::Vector(result))
        }
        _ => Ok(form.clone()),
    }
}

fn eval_defmacro(list: &[Value], env: &mut Env) -> Result<Value, String> {
    if list.len() != 4 {
        return Err("defmacro requires exactly 3 arguments".to_string());
    }

    if let Value::Symbol(name) = &list[1] {
        let params = match &list[2] {
            Value::Vector(params) => {
                let mut param_names = Vec::new();
                for param in params {
                    if let Value::Symbol(pname) = param {
                        param_names.push(pname.clone());
                    } else {
                        return Err("Macro parameters must be symbols".to_string());
                    }
                }
                param_names
            }
            _ => return Err("Macro parameters must be a vector".to_string()),
        };

        let body = list[3].clone();
        let captured_env = env.clone();

        let macro_fn = Value::Function(Function::Macro {
            params,
            body: Box::new(body),
            env: captured_env,
        });
        
        env.set_namespaced(name.clone(), macro_fn.clone());
        Ok(macro_fn)
    } else {
        Err("First argument to defmacro must be a symbol".to_string())
    }
}

fn eval_macroexpand(list: &[Value], env: &Env) -> Result<Value, String> {
    if list.len() != 2 {
        return Err("macroexpand requires exactly 1 argument".to_string());
    }
    // Evaluate the argument to get the actual form
    let form = match &list[1] {
        Value::List(inner) if !inner.is_empty() => {
            if let Value::Symbol(sym) = &inner[0] {
                if sym == "quote" && inner.len() == 2 {
                    &inner[1]
                } else {
                    &list[1]
                }
            } else {
                &list[1]
            }
        }
        _ => &list[1]
    };
    macroexpand(form, env)
}

fn eval_let(list: &[Value], env: &mut Env) -> Result<Value, String> {
    if list.len() != 3 {
        return Err("let requires exactly 2 arguments".to_string());
    }

    let bindings = match &list[1] {
        Value::Vector(bindings) => bindings,
        _ => return Err("let bindings must be a vector".to_string()),
    };

    if bindings.len() % 2 != 0 {
        return Err("let bindings must have an even number of elements".to_string());
    }

    // Create new environment
    let mut local_env = Env::with_parent(env.clone());

    // Process bindings sequentially (like Clojure let, not letrec)
    let mut i = 0;
    while i < bindings.len() {
        if let Value::Symbol(name) = &bindings[i] {
            let value = eval(&bindings[i + 1], &mut local_env)?;
            local_env.set(name.clone(), value);
        } else {
            return Err("Binding names must be symbols".to_string());
        }
        i += 2;
    }

    // Evaluate body in local environment
    eval(&list[2], &mut local_env)
}

fn eval_letrec(list: &[Value], env: &mut Env) -> Result<Value, String> {
    if list.len() != 3 {
        return Err("letrec requires exactly 2 arguments".to_string());
    }

    let bindings = match &list[1] {
        Value::Vector(bindings) => bindings,
        _ => return Err("letrec bindings must be a vector".to_string()),
    };

    // Create new environment
    let mut local_env = Env::with_parent(env.clone());

    // Step 1: Pre-bind all names to Uninitialized
    let mut binding_names = Vec::new();
    for binding in bindings {
        if let Value::Vector(pair) = binding {
            if pair.len() != 2 {
                return Err("Each binding must be a vector of [name value]".to_string());
            }
            if let Value::Symbol(name) = &pair[0] {
                binding_names.push(name.clone());
                local_env.set(name.clone(), Value::Uninitialized);
            } else {
                return Err("Binding name must be a symbol".to_string());
            }
        } else {
            return Err("Each binding must be a vector".to_string());
        }
    }

    // Step 2: Evaluate each RHS and immediately update
    for (i, binding) in bindings.iter().enumerate() {
        if let Value::Vector(pair) = binding {
            let name = &binding_names[i];
            let value = eval(&pair[1], &mut local_env)?;
            local_env.update(name, value)?;
        }
    }

    // Step 3: Evaluate the body
    eval(&list[2], &mut local_env)
}

fn eval_fn(list: &[Value], env: &mut Env) -> Result<Value, String> {
    if list.len() != 3 {
        return Err("fn requires exactly 2 arguments".to_string());
    }

    let params = match &list[1] {
        Value::Vector(params) => {
            let mut param_names = Vec::new();
            for param in params {
                if let Value::Symbol(name) = param {
                    param_names.push(name.clone());
                } else {
                    return Err("Function parameters must be symbols".to_string());
                }
            }
            param_names
        }
        _ => return Err("Function parameters must be a vector".to_string()),
    };

    let body = list[2].clone();
    let captured_env = env.clone();

    Ok(Value::Function(Function::UserDefined {
        params,
        body: Box::new(body),
        env: captured_env,
    }))
}

fn eval_load(list: &[Value], env: &mut Env) -> Result<Value, String> {
    if list.len() != 2 {
        return Err("load requires exactly 1 argument".to_string());
    }

    // Evaluate the filename argument
    let filename_val = eval(&list[1], env)?;
    let filename = match filename_val {
        Value::Str(s) => s,
        _ => return Err("load requires a string filename".to_string()),
    };

    // Read the file
    let content = match std::fs::read_to_string(&filename) {
        Ok(content) => content,
        Err(e) => return Err(format!("Failed to read file '{}': {}", filename, e)),
    };

    // Parse all forms from the file using read_all_forms
    use crate::reader::read_all_forms;
    
    let forms = match read_all_forms(&content) {
        Ok(forms) => forms,
        Err(e) => return Err(format!("Parse error in '{}': {}", filename, e)),
    };

    // Evaluate each form in order
    let mut last_result = Value::Nil;
    for form in forms {
        match eval(&form, env) {
            Ok(result) => last_result = result,
            Err(e) => return Err(format!("Error evaluating expression in '{}': {}", filename, e)),
        }
    }

    Ok(last_result)
}

fn eval_call(list: &[Value], env: &mut Env) -> Result<Value, String> {
    // First check if it's a macro call
    if let Value::Symbol(name) = &list[0] {
        if let Some(value) = env.get_with_aliases(name) {
            if let Value::Function(Function::Macro { params, body, env: macro_env }) = value {
                // It's a macro - expand it first
                let expanded = expand_macro(&params, &body, &list[1..], &macro_env)?;
                // Then evaluate the expanded form
                return eval(&expanded, env);
            }
        }
    }
    
    // Not a macro, evaluate normally
    let mut evaluated = Vec::new();
    for item in list {
        let val = eval(item, env)?;
        // if let Value::Uninitialized = val {
        //     return Err(format!("Cannot call uninitialized function: {:?}", item));
        // }
        evaluated.push(val);
    }

    // Handle keywords as functions to access map values
    if let Value::Keyword(key) = &evaluated[0] {
        if evaluated.len() != 2 {
            return Err("Keyword as function requires exactly 1 argument".to_string());
        }
        match &evaluated[1] {
            Value::Map(map) => {
                return Ok(map.get(key).cloned().unwrap_or(Value::Nil));
            }
            _ => return Err("Keyword as function requires a map argument".to_string()),
        }
    }
    
    if let Value::Function(func) = &evaluated[0] {
        match func {
            Function::Native(f) => f(&evaluated[1..]),
            Function::UserDefined { params, body, env: captured_env } => {
                if evaluated.len() - 1 != params.len() {
                    return Err(format!(
                        "Function expects {} arguments, got {}",
                        params.len(),
                        evaluated.len() - 1
                    ));
                }

                // Universal self-reference: lightweight fix for all function calls
                let self_ref_name = if let Value::Symbol(func_name) = &list[0] {
                    if let Some(slash_pos) = func_name.rfind('/') {
                        Some(&func_name[slash_pos + 1..])
                    } else {
                        Some(func_name.as_str())
                    }
                } else {
                    None
                };

                eval_user_function_with_tco(params, body, captured_env, &evaluated[1..], env, self_ref_name, &evaluated[0])
            }
            Function::Macro { .. } => {
                Err("Macros should be expanded before evaluation".to_string())
            }
        }
    } else {
        Err(format!("Cannot call non-function: {:?}", evaluated[0]))
    }
}

// Thread-local recursion depth counter to prevent stack overflow
thread_local! {
    static RECURSION_DEPTH: RefCell<usize> = RefCell::new(0);
}

const MAX_RECURSION_DEPTH: usize = 1000;

fn eval_user_function_with_tco(params: &[String], body: &Value, captured_env: &Env, args: &[Value], _current_env: &Env, self_ref_name: Option<&str>, func_value: &Value) -> Result<Value, String> {
    // Check recursion depth to prevent stack overflow
    let current_depth = RECURSION_DEPTH.with(|d| {
        let depth = *d.borrow();
        *d.borrow_mut() = depth + 1;
        depth + 1
    });
    
    if current_depth > MAX_RECURSION_DEPTH {
        RECURSION_DEPTH.with(|d| *d.borrow_mut() -= 1);
        return Err(format!("Maximum recursion depth {} exceeded", MAX_RECURSION_DEPTH));
    }
    
    // Create local environment with captured environment as parent for proper closure support
    let mut local_env = Env::with_parent(captured_env.clone());
    
    // Add self-reference for recursion support (prevents infinite loops in qualified/aliased calls)
    if let Some(unqualified_name) = self_ref_name {
        local_env.set(unqualified_name.to_string(), func_value.clone());
    }
    
    // Bind arguments to parameters
    for (param, arg) in params.iter().zip(args) {
        local_env.set(param.clone(), arg.clone());
    }
    
    // Evaluate function body
    let result = eval(body, &mut local_env);
    
    // Decrement recursion depth
    RECURSION_DEPTH.with(|d| *d.borrow_mut() -= 1);
    
    result
}

fn expand_macro(params: &[String], body: &Value, args: &[Value], macro_env: &Env) -> Result<Value, String> {
    if args.len() != params.len() {
        return Err(format!(
            "Macro expects {} arguments, got {}",
            params.len(),
            args.len()
        ));
    }
    
    let mut expansion_env = Env::with_parent(macro_env.clone());
    for (param, arg) in params.iter().zip(args) {
        expansion_env.set(param.clone(), arg.clone());
    }
    
    eval(body, &mut expansion_env)
}

fn expand_macro_form(params: &[String], body: &Value, args: &[Value], macro_env: &Env) -> Result<Value, String> {
    if args.len() != params.len() {
        return Err(format!(
            "Macro expects {} arguments, got {}",
            params.len(),
            args.len()
        ));
    }
    
    // Create expansion environment with parameter bindings
    let mut expansion_env = Env::with_parent(macro_env.clone());
    for (param, arg) in params.iter().zip(args) {
        expansion_env.set(param.clone(), arg.clone());
    }
    
    // If the body is a quasiquote, evaluate it to get the expanded form
    // Otherwise, do symbol substitution
    match body {
        Value::List(items) if !items.is_empty() => {
            if let Value::Symbol(sym) = &items[0] {
                if sym == "quasiquote" && items.len() == 2 {
                    // This is a quasiquote - evaluate it to get the expansion
                    eval_quasiquote_form(&items[1], &mut expansion_env)
                } else {
                    // Regular form - do symbol substitution
                    let mut substitutions = std::collections::HashMap::new();
                    for (param, arg) in params.iter().zip(args) {
                        substitutions.insert(param.clone(), arg.clone());
                    }
                    substitute_symbols(body, &substitutions)
                }
            } else {
                // Non-symbol first element - do symbol substitution
                let mut substitutions = std::collections::HashMap::new();
                for (param, arg) in params.iter().zip(args) {
                    substitutions.insert(param.clone(), arg.clone());
                }
                substitute_symbols(body, &substitutions)
            }
        }
        _ => {
            // Non-list body - do symbol substitution
            let mut substitutions = std::collections::HashMap::new();
            for (param, arg) in params.iter().zip(args) {
                substitutions.insert(param.clone(), arg.clone());
            }
            substitute_symbols(body, &substitutions)
        }
    }
}

fn substitute_symbols(expr: &Value, substitutions: &std::collections::HashMap<String, Value>) -> Result<Value, String> {
    match expr {
        Value::Symbol(name) => {
            if let Some(replacement) = substitutions.get(name) {
                Ok(replacement.clone())
            } else {
                Ok(expr.clone())
            }
        }
        Value::List(items) => {
            let mut result = Vec::new();
            for item in items {
                result.push(substitute_symbols(item, substitutions)?);
            }
            Ok(Value::List(result))
        }
        Value::Vector(items) => {
            let mut result = Vec::new();
            for item in items {
                result.push(substitute_symbols(item, substitutions)?);
            }
            Ok(Value::Vector(result))
        }
        _ => Ok(expr.clone())
    }
}

pub fn create_default_env() -> Env {
    let mut env = Env::new();

    env.set(
        "+".to_string(),
        Value::Function(Function::Native(|args| {
            let mut sum = 0.0;
            for arg in args {
                if let Value::Number(n) = arg {
                    sum += n;
                } else {
                    return Err(format!("+ requires numbers, got {:?}", arg));
                }
            }
            Ok(Value::Number(sum))
        })),
    );

    env.set(
        "-".to_string(),
        Value::Function(Function::Native(|args| {
            if args.is_empty() {
                return Err("- requires at least 1 argument".to_string());
            }
            if let Value::Number(first) = &args[0] {
                if args.len() == 1 {
                    Ok(Value::Number(-first))
                } else {
                    let mut result = *first;
                    for arg in &args[1..] {
                        if let Value::Number(n) = arg {
                            result -= n;
                        } else {
                            return Err(format!("- requires numbers, got {:?}", arg));
                        }
                    }
                    Ok(Value::Number(result))
                }
            } else {
                Err(format!("- requires numbers, got {:?}", args[0]))
            }
        })),
    );

    env.set(
        "*".to_string(),
        Value::Function(Function::Native(|args| {
            let mut product = 1.0;
            for arg in args {
                if let Value::Number(n) = arg {
                    product *= n;
                } else {
                    return Err(format!("* requires numbers, got {:?}", arg));
                }
            }
            Ok(Value::Number(product))
        })),
    );

    env.set(
        "/".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() < 2 {
                return Err("/ requires at least 2 arguments".to_string());
            }
            if let Value::Number(first) = &args[0] {
                let mut result = *first;
                for arg in &args[1..] {
                    if let Value::Number(n) = arg {
                        if *n == 0.0 {
                            return Err("Division by zero".to_string());
                        }
                        result /= n;
                    } else {
                        return Err(format!("/ requires numbers, got {:?}", arg));
                    }
                }
                Ok(Value::Number(result))
            } else {
                Err(format!("/ requires numbers, got {:?}", args[0]))
            }
        })),
    );

    env.set(
        "%".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 2 {
                return Err("% requires exactly 2 arguments".to_string());
            }
            if let (Value::Number(a), Value::Number(b)) = (&args[0], &args[1]) {
                if *b == 0.0 {
                    return Err("Modulo by zero".to_string());
                }
                Ok(Value::Number(a % b))
            } else {
                Err("% requires numbers".to_string())
            }
        })),
    );

    env.set(
        "=".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() < 2 {
                return Err("= requires at least 2 arguments".to_string());
            }
            for i in 1..args.len() {
                if args[i] != args[0] {
                    return Ok(Value::Bool(false));
                }
            }
            Ok(Value::Bool(true))
        })),
    );

    env.set(
        "not=".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 2 {
                return Err("not= requires exactly 2 arguments".to_string());
            }
            Ok(Value::Bool(args[0] != args[1]))
        })),
    );

    env.set(
        "print".to_string(),
        Value::Function(Function::Native(|args| {
            for (i, arg) in args.iter().enumerate() {
                if i > 0 {
                    print!(" ");
                }
                print!("{}", arg);
            }
            println!();
            Ok(Value::Nil)
        })),
    );

    // Comparison functions
    env.set(
        "<".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 2 {
                return Err("< requires exactly 2 arguments".to_string());
            }
            if let (Value::Number(a), Value::Number(b)) = (&args[0], &args[1]) {
                Ok(Value::Bool(a < b))
            } else {
                Err("< requires numbers".to_string())
            }
        })),
    );

    env.set(
        ">".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 2 {
                return Err("> requires exactly 2 arguments".to_string());
            }
            if let (Value::Number(a), Value::Number(b)) = (&args[0], &args[1]) {
                Ok(Value::Bool(a > b))
            } else {
                Err("> requires numbers".to_string())
            }
        })),
    );

    // List operations
    env.set(
        "cons".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 2 {
                return Err("cons requires exactly 2 arguments".to_string());
            }
            if let Value::List(list) = &args[1] {
                let mut new_list = vec![args[0].clone()];
                new_list.extend(list.iter().cloned());
                Ok(Value::List(new_list))
            } else if args[1] == Value::Nil {
                Ok(Value::List(vec![args[0].clone()]))
            } else {
                Err("cons requires a list as second argument".to_string())
            }
        })),
    );

    env.set(
        "first".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("first requires exactly 1 argument".to_string());
            }
            match &args[0] {
                Value::List(list) => {
                    if list.is_empty() {
                        Ok(Value::Nil)
                    } else {
                        Ok(list[0].clone())
                    }
                }
                Value::Nil => Ok(Value::Nil),
                _ => Err("first requires a list".to_string()),
            }
        })),
    );

    env.set(
        "rest".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("rest requires exactly 1 argument".to_string());
            }
            match &args[0] {
                Value::List(list) => {
                    if list.is_empty() {
                        Ok(Value::Nil)
                    } else if list.len() == 1 {
                        Ok(Value::Nil)  // rest of single-element list is nil
                    } else {
                        Ok(Value::List(list[1..].to_vec()))
                    }
                }
                Value::Nil => Ok(Value::Nil),
                _ => Err("rest requires a list".to_string()),
            }
        })),
    );

    env.set(
        "not".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("not requires exactly 1 argument".to_string());
            }
            match &args[0] {
                Value::Bool(false) | Value::Nil => Ok(Value::Bool(true)),
                _ => Ok(Value::Bool(false)),
            }
        })),
    );

    // Additional comparison functions
    env.set(
        ">=".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 2 {
                return Err(">= requires exactly 2 arguments".to_string());
            }
            match (&args[0], &args[1]) {
                (Value::Number(a), Value::Number(b)) => Ok(Value::Bool(a >= b)),
                _ => Err(">= requires numbers".to_string())
            }
        })),
    );

    env.set(
        "<=".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 2 {
                return Err("<= requires exactly 2 arguments".to_string());
            }
            match (&args[0], &args[1]) {
                (Value::Number(a), Value::Number(b)) => Ok(Value::Bool(a <= b)),
                _ => Err("<= requires numbers".to_string())
            }
        })),
    );

    // List constructor
    env.set(
        "list".to_string(),
        Value::Function(Function::Native(|args| {
            if args.is_empty() {
                Ok(Value::Nil)  // (list) with no args returns nil
            } else {
                Ok(Value::List(args.to_vec()))
            }
        })),
    );

    // Time functions
    env.set(
        "now".to_string(),
        Value::Function(Function::Native(|args| {
            if !args.is_empty() {
                return Err("now takes no arguments".to_string());
            }
            use std::time::{SystemTime, UNIX_EPOCH};
            let duration = SystemTime::now()
                .duration_since(UNIX_EPOCH)
                .map_err(|_| "Time error".to_string())?;
            Ok(Value::Number(duration.as_millis() as f64))
        })),
    );

    // Map operations
    env.set(
        "get".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 2 {
                return Err("get requires exactly 2 arguments".to_string());
            }
            match (&args[0], &args[1]) {
                (Value::Map(map), Value::Keyword(key)) => {
                    Ok(map.get(key).cloned().unwrap_or(Value::Nil))
                }
                (Value::Map(map), Value::Str(key)) => {
                    Ok(map.get(key).cloned().unwrap_or(Value::Nil))
                }
                _ => Err("get requires a map and a key".to_string())
            }
        })),
    );

    env.set(
        "assoc".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 3 {
                return Err("assoc requires exactly 3 arguments".to_string());
            }
            match &args[0] {
                Value::Map(map) => {
                    let mut new_map = map.clone();
                    let key = match &args[1] {
                        Value::Keyword(k) => k.clone(),
                        Value::Str(s) => s.clone(),
                        _ => return Err("assoc key must be a keyword or string".to_string()),
                    };
                    new_map.insert(key, args[2].clone());
                    Ok(Value::Map(new_map))
                }
                _ => Err("assoc requires a map as first argument".to_string())
            }
        })),
    );

    // Collection operations
    env.set(
        "contains?".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 2 {
                return Err("contains? requires exactly 2 arguments".to_string());
            }
            match (&args[0], &args[1]) {
                (Value::List(list), value) => {
                    Ok(Value::Bool(list.contains(value)))
                }
                (Value::Map(map), Value::Keyword(key)) => {
                    Ok(Value::Bool(map.contains_key(key)))
                }
                (Value::Map(map), Value::Str(key)) => {
                    Ok(Value::Bool(map.contains_key(key)))
                }
                _ => Err("contains? requires a list/map and a value".to_string())
            }
        })),
    );

    // String operations

    env.set(
        "str-length".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("str-length requires exactly 1 argument".to_string());
            }
            match &args[0] {
                Value::Str(s) => Ok(Value::Number(s.len() as f64)),
                _ => Err("str-length requires a string".to_string()),
            }
        })),
    );

    env.set(
        "str".to_string(),
        Value::Function(Function::Native(|args| {
            let mut result = String::new();
            for arg in args {
                match arg {
                    Value::Str(s) => result.push_str(s),
                    Value::Number(n) => result.push_str(&n.to_string()),
                    Value::Bool(b) => result.push_str(&b.to_string()),
                    Value::Nil => result.push_str("nil"),
                    Value::Symbol(s) => result.push_str(s),
                    Value::Keyword(k) => result.push_str(k),
                    Value::List(l) => {
                        let items: Vec<String> = l.iter().map(|v| v.to_string()).collect();
                        result.push_str(&format!("({})", items.join(" ")));
                    }
                    Value::Function(f) => match f {
                        Function::Macro { .. } => result.push_str("#<macro>"),
                        _ => result.push_str("#<function>"),
                    },
                    Value::Vector(v) => {
                        let items: Vec<String> = v.iter().map(|val| val.to_string()).collect();
                        result.push_str(&format!("[{}]", items.join(" ")));
                    }
                    Value::Map(m) => {
                        let pairs: Vec<String> = m.iter()
                            .map(|(k, v)| format!("{} {}", k, v))
                            .collect();
                        result.push_str(&format!("{{{}}}", pairs.join(" ")));
                    }
                    Value::IOResource(resource) => match resource {
                        IOResource::Reader(_) => result.push_str("#<reader>"),
                        IOResource::Writer(_) => result.push_str("#<writer>"),
                        IOResource::InputStream(_) => result.push_str("#<input-stream>"),
                        IOResource::OutputStream(_) => result.push_str("#<output-stream>"),
                    },
                    Value::Uninitialized => result.push_str("#<uninitialized>"),
                }
            }
            Ok(Value::Str(result))
        })),
    );

    // Time functions
    env.set(
        "now-ms".to_string(),
        Value::Function(Function::Native(|args| {
            if !args.is_empty() {
                return Err("now-ms takes no arguments".to_string());
            }
            use std::time::{SystemTime, UNIX_EPOCH};
            match SystemTime::now().duration_since(UNIX_EPOCH) {
                Ok(duration) => Ok(Value::Number(duration.as_millis() as f64)),
                Err(_) => Err("Failed to get system time".to_string()),
            }
        })),
    );

    env.set(
        "sleep-ms".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("sleep-ms requires exactly 1 argument".to_string());
            }
            match &args[0] {
                Value::Number(ms) => {
                    if *ms >= 0.0 {
                        std::thread::sleep(std::time::Duration::from_millis(*ms as u64));
                        Ok(Value::Nil)
                    } else {
                        Err("sleep-ms requires a non-negative number".to_string())
                    }
                }
                _ => Err("sleep-ms requires a number".to_string()),
            }
        })),
    );

    // Test result counters - global state for tracking
    use std::sync::atomic::{AtomicUsize, Ordering};
    
    static PASS_COUNT: AtomicUsize = AtomicUsize::new(0);
    static FAIL_COUNT: AtomicUsize = AtomicUsize::new(0);
    
    // Enhanced assert-eq that tracks results
    env.set(
        "test-assert-eq".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 2 {
                return Err("test-assert-eq requires exactly 2 arguments".to_string());
            }
            
            if args[0] == args[1] {
                PASS_COUNT.fetch_add(1, Ordering::SeqCst);
                println!("  PASS: {} == {}", args[0], args[1]);
                Ok(Value::Bool(true))
            } else {
                FAIL_COUNT.fetch_add(1, Ordering::SeqCst);
                println!("  FAIL: expected {} but got {}", args[0], args[1]);
                Ok(Value::Bool(false))
            }
        })),
    );

    // Functions to access test counters
    env.set(
        "get-pass-count".to_string(),
        Value::Function(Function::Native(|_args| {
            Ok(Value::Number(PASS_COUNT.load(Ordering::SeqCst) as f64))
        })),
    );

    env.set(
        "get-fail-count".to_string(),
        Value::Function(Function::Native(|_args| {
            Ok(Value::Number(FAIL_COUNT.load(Ordering::SeqCst) as f64))
        })),
    );

    env.set(
        "reset-test-counts".to_string(),
        Value::Function(Function::Native(|_args| {
            PASS_COUNT.store(0, Ordering::SeqCst);
            FAIL_COUNT.store(0, Ordering::SeqCst);
            Ok(Value::Nil)
        })),
    );

    // Test runner function that actually runs tests
    env.set(
        "run-tests".to_string(),
        Value::Function(Function::Native(|_args| {
            // Reset counters
            PASS_COUNT.store(0, Ordering::SeqCst);
            FAIL_COUNT.store(0, Ordering::SeqCst);
            
            println!("🧪 CORTADO COMPREHENSIVE TEST SUITE");
            println!("=====================================");
            
            // We need to run this in the current environment context
            // Return a special value that the caller can interpret
            Ok(Value::Symbol("__RUN_COMPREHENSIVE_TESTS__".to_string()))
        })),
    );

    // File I/O functions (legacy - kept for compatibility)
    env.set(
        "read-file".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("read-file requires exactly 1 argument".to_string());
            }
            match &args[0] {
                Value::Str(filename) => {
                    match std::fs::read_to_string(filename) {
                        Ok(content) => Ok(Value::Str(content)),
                        Err(e) => Err(format!("Failed to read file '{}': {}", filename, e)),
                    }
                }
                _ => Err("read-file requires a string filename".to_string()),
            }
        })),
    );

    env.set(
        "write-file".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 2 {
                return Err("write-file requires exactly 2 arguments".to_string());
            }
            match (&args[0], &args[1]) {
                (Value::Str(filename), Value::Str(content)) => {
                    match std::fs::write(filename, content) {
                        Ok(_) => Ok(Value::Nil),
                        Err(e) => Err(format!("Failed to write file '{}': {}", filename, e)),
                    }
                }
                _ => Err("write-file requires string filename and content".to_string()),
            }
        })),
    );

    // Enhanced I/O functions (Clojure-inspired)
    env.set(
        "reader".to_string(),
        Value::Function(Function::Native(|args| {
            if args.is_empty() || args.len() > 2 {
                return Err("reader requires 1-2 arguments".to_string());
            }
            
            let source = &args[0];
            let _opts = if args.len() == 2 { Some(&args[1]) } else { None };
            
            match source {
                Value::Str(filename) => {
                    match std::fs::File::open(filename) {
                        Ok(file) => {
                            let buf_reader = std::io::BufReader::new(file);
                            let resource = IOResource::Reader(Arc::new(Mutex::new(Box::new(buf_reader))));
                            Ok(Value::IOResource(resource))
                        }
                        Err(e) => Err(format!("Failed to open file '{}': {}", filename, e)),
                    }
                }
                Value::Keyword(k) if k == "stdin" => {
                    let stdin = std::io::stdin();
                    let buf_reader = std::io::BufReader::new(stdin);
                    let resource = IOResource::Reader(Arc::new(Mutex::new(Box::new(buf_reader))));
                    Ok(Value::IOResource(resource))
                }
                _ => Err("reader requires a string filename or :stdin".to_string()),
            }
        })),
    );

    env.set(
        "writer".to_string(),
        Value::Function(Function::Native(|args| {
            if args.is_empty() || args.len() > 2 {
                return Err("writer requires 1-2 arguments".to_string());
            }
            
            let dest = &args[0];
            let _opts = if args.len() == 2 { Some(&args[1]) } else { None };
            
            match dest {
                Value::Str(filename) => {
                    match std::fs::File::create(filename) {
                        Ok(file) => {
                            let buf_writer = std::io::BufWriter::new(file);
                            let resource = IOResource::Writer(Arc::new(Mutex::new(Box::new(buf_writer))));
                            Ok(Value::IOResource(resource))
                        }
                        Err(e) => Err(format!("Failed to create file '{}': {}", filename, e)),
                    }
                }
                Value::Keyword(k) if k == "stdout" => {
                    let stdout = std::io::stdout();
                    let buf_writer = std::io::BufWriter::new(stdout);
                    let resource = IOResource::Writer(Arc::new(Mutex::new(Box::new(buf_writer))));
                    Ok(Value::IOResource(resource))
                }
                Value::Keyword(k) if k == "stderr" => {
                    let stderr = std::io::stderr();
                    let buf_writer = std::io::BufWriter::new(stderr);
                    let resource = IOResource::Writer(Arc::new(Mutex::new(Box::new(buf_writer))));
                    Ok(Value::IOResource(resource))
                }
                _ => Err("writer requires a string filename or :stdout/:stderr".to_string()),
            }
        })),
    );

    env.set(
        "input-stream".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("input-stream requires exactly 1 argument".to_string());
            }
            
            match &args[0] {
                Value::Str(filename) => {
                    match std::fs::File::open(filename) {
                        Ok(file) => {
                            let resource = IOResource::InputStream(Arc::new(Mutex::new(Box::new(file))));
                            Ok(Value::IOResource(resource))
                        }
                        Err(e) => Err(format!("Failed to open file '{}': {}", filename, e)),
                    }
                }
                _ => Err("input-stream requires a string filename".to_string()),
            }
        })),
    );

    env.set(
        "output-stream".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("output-stream requires exactly 1 argument".to_string());
            }
            
            match &args[0] {
                Value::Str(filename) => {
                    match std::fs::File::create(filename) {
                        Ok(file) => {
                            let resource = IOResource::OutputStream(Arc::new(Mutex::new(Box::new(file))));
                            Ok(Value::IOResource(resource))
                        }
                        Err(e) => Err(format!("Failed to create file '{}': {}", filename, e)),
                    }
                }
                _ => Err("output-stream requires a string filename".to_string()),
            }
        })),
    );

    // Enhanced I/O operations (slurp, spit, copy)
    env.set(
        "slurp".to_string(),
        Value::Function(Function::Native(|args| {
            if args.is_empty() || args.len() > 2 {
                return Err("slurp requires 1-2 arguments".to_string());
            }
            
            let source = &args[0];
            let _opts = if args.len() == 2 { Some(&args[1]) } else { None };
            
            match source {
                Value::Str(filename) => {
                    match std::fs::read_to_string(filename) {
                        Ok(content) => Ok(Value::Str(content)),
                        Err(e) => Err(format!("Failed to read file '{}': {}", filename, e)),
                    }
                }
                Value::IOResource(IOResource::Reader(reader)) => {
                    match reader.lock() {
                        Ok(mut r) => {
                            let mut content = String::new();
                            match r.read_to_string(&mut content) {
                                Ok(_) => Ok(Value::Str(content)),
                                Err(e) => Err(format!("Failed to read from reader: {}", e)),
                            }
                        }
                        Err(e) => Err(format!("Failed to lock reader: {}", e)),
                    }
                }
                _ => Err("slurp requires a string filename or reader".to_string()),
            }
        })),
    );

    env.set(
        "spit".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() < 2 || args.len() > 3 {
                return Err("spit requires 2-3 arguments".to_string());
            }
            
            let dest = &args[0];
            let content = &args[1];
            let _opts = if args.len() == 3 { Some(&args[2]) } else { None };
            
            let content_str = match content {
                Value::Str(s) => s.clone(),
                other => format!("{}", other),
            };
            
            match dest {
                Value::Str(filename) => {
                    match std::fs::write(filename, content_str) {
                        Ok(_) => Ok(Value::Nil),
                        Err(e) => Err(format!("Failed to write file '{}': {}", filename, e)),
                    }
                }
                Value::IOResource(IOResource::Writer(writer)) => {
                    match writer.lock() {
                        Ok(mut w) => {
                            match w.write_all(content_str.as_bytes()) {
                                Ok(_) => {
                                    match w.flush() {
                                        Ok(_) => Ok(Value::Nil),
                                        Err(e) => Err(format!("Failed to flush writer: {}", e)),
                                    }
                                }
                                Err(e) => Err(format!("Failed to write to writer: {}", e)),
                            }
                        }
                        Err(e) => Err(format!("Failed to lock writer: {}", e)),
                    }
                }
                _ => Err("spit requires a string filename or writer".to_string()),
            }
        })),
    );

    env.set(
        "copy".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() < 2 || args.len() > 3 {
                return Err("copy requires 2-3 arguments".to_string());
            }
            
            let input = &args[0];
            let output = &args[1];
            let _opts = if args.len() == 3 { Some(&args[2]) } else { None };
            
            match (input, output) {
                (Value::IOResource(IOResource::Reader(reader)), Value::IOResource(IOResource::Writer(writer))) => {
                    match (reader.lock(), writer.lock()) {
                        (Ok(mut r), Ok(mut w)) => {
                            match std::io::copy(&mut *r, &mut *w) {
                                Ok(bytes_copied) => Ok(Value::Number(bytes_copied as f64)),
                                Err(e) => Err(format!("Failed to copy data: {}", e)),
                            }
                        }
                        _ => Err("Failed to lock reader or writer".to_string()),
                    }
                }
                (Value::Str(input_file), Value::Str(output_file)) => {
                    match std::fs::copy(input_file, output_file) {
                        Ok(bytes_copied) => Ok(Value::Number(bytes_copied as f64)),
                        Err(e) => Err(format!("Failed to copy file '{}' to '{}': {}", input_file, output_file, e)),
                    }
                }
                _ => Err("copy requires two strings (filenames) or a reader and writer".to_string()),
            }
        })),
    );

    // File system operations
    env.set(
        "file-exists?".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("file-exists? requires exactly 1 argument".to_string());
            }
            match &args[0] {
                Value::Str(path) => {
                    Ok(Value::Bool(std::path::Path::new(path).exists()))
                }
                _ => Err("file-exists? requires a string path".to_string()),
            }
        })),
    );

    env.set(
        "directory?".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("directory? requires exactly 1 argument".to_string());
            }
            match &args[0] {
                Value::Str(path) => {
                    Ok(Value::Bool(std::path::Path::new(path).is_dir()))
                }
                _ => Err("directory? requires a string path".to_string()),
            }
        })),
    );

    env.set(
        "file-size".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("file-size requires exactly 1 argument".to_string());
            }
            match &args[0] {
                Value::Str(path) => {
                    match std::fs::metadata(path) {
                        Ok(metadata) => Ok(Value::Number(metadata.len() as f64)),
                        Err(e) => Err(format!("Failed to get file size for '{}': {}", path, e)),
                    }
                }
                _ => Err("file-size requires a string path".to_string()),
            }
        })),
    );

    env.set(
        "copy-file".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 2 {
                return Err("copy-file requires exactly 2 arguments".to_string());
            }
            match (&args[0], &args[1]) {
                (Value::Str(src), Value::Str(dest)) => {
                    match std::fs::copy(src, dest) {
                        Ok(bytes_copied) => Ok(Value::Number(bytes_copied as f64)),
                        Err(e) => Err(format!("Failed to copy file '{}' to '{}': {}", src, dest, e)),
                    }
                }
                _ => Err("copy-file requires two string paths".to_string()),
            }
        })),
    );

    env.set(
        "move-file".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 2 {
                return Err("move-file requires exactly 2 arguments".to_string());
            }
            match (&args[0], &args[1]) {
                (Value::Str(src), Value::Str(dest)) => {
                    match std::fs::rename(src, dest) {
                        Ok(_) => Ok(Value::Nil),
                        Err(e) => Err(format!("Failed to move file '{}' to '{}': {}", src, dest, e)),
                    }
                }
                _ => Err("move-file requires two string paths".to_string()),
            }
        })),
    );

    env.set(
        "delete-file".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("delete-file requires exactly 1 argument".to_string());
            }
            match &args[0] {
                Value::Str(path) => {
                    match std::fs::remove_file(path) {
                        Ok(_) => Ok(Value::Nil),
                        Err(e) => Err(format!("Failed to delete file '{}': {}", path, e)),
                    }
                }
                _ => Err("delete-file requires a string path".to_string()),
            }
        })),
    );

    // Directory operations
    env.set(
        "list-dir".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("list-dir requires exactly 1 argument".to_string());
            }
            match &args[0] {
                Value::Str(path) => {
                    match std::fs::read_dir(path) {
                        Ok(entries) => {
                            let mut result = Vec::new();
                            for entry in entries {
                                match entry {
                                    Ok(entry) => {
                                        if let Some(name) = entry.file_name().to_str() {
                                            result.push(Value::Str(name.to_string()));
                                        }
                                    }
                                    Err(e) => return Err(format!("Failed to read directory entry: {}", e)),
                                }
                            }
                            Ok(Value::List(result))
                        }
                        Err(e) => Err(format!("Failed to read directory '{}': {}", path, e)),
                    }
                }
                _ => Err("list-dir requires a string path".to_string()),
            }
        })),
    );

    env.set(
        "create-dir".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("create-dir requires exactly 1 argument".to_string());
            }
            match &args[0] {
                Value::Str(path) => {
                    match std::fs::create_dir_all(path) {
                        Ok(_) => Ok(Value::Nil),
                        Err(e) => Err(format!("Failed to create directory '{}': {}", path, e)),
                    }
                }
                _ => Err("create-dir requires a string path".to_string()),
            }
        })),
    );

    env.set(
        "delete-dir".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("delete-dir requires exactly 1 argument".to_string());
            }
            match &args[0] {
                Value::Str(path) => {
                    match std::fs::remove_dir_all(path) {
                        Ok(_) => Ok(Value::Nil),
                        Err(e) => Err(format!("Failed to delete directory '{}': {}", path, e)),
                    }
                }
                _ => Err("delete-dir requires a string path".to_string()),
            }
        })),
    );

    // Enhanced standard I/O operations
    env.set(
        "read-line".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() > 1 {
                return Err("read-line requires 0-1 arguments".to_string());
            }
            
            if args.is_empty() {
                // Read from stdin
                let mut line = String::new();
                match std::io::stdin().read_line(&mut line) {
                    Ok(_) => {
                        // Remove trailing newline
                        if line.ends_with('\n') {
                            line.pop();
                            if line.ends_with('\r') {
                                line.pop();
                            }
                        }
                        Ok(Value::Str(line))
                    }
                    Err(e) => Err(format!("Failed to read line from stdin: {}", e)),
                }
            } else {
                // Read from reader
                match &args[0] {
                    Value::IOResource(IOResource::Reader(reader)) => {
                        match reader.lock() {
                            Ok(mut r) => {
                                let mut line = String::new();
                                match r.read_line(&mut line) {
                                    Ok(0) => Ok(Value::Nil), // EOF
                                    Ok(_) => {
                                        // Remove trailing newline
                                        if line.ends_with('\n') {
                                            line.pop();
                                            if line.ends_with('\r') {
                                                line.pop();
                                            }
                                        }
                                        Ok(Value::Str(line))
                                    }
                                    Err(e) => Err(format!("Failed to read line from reader: {}", e)),
                                }
                            }
                            Err(e) => Err(format!("Failed to lock reader: {}", e)),
                        }
                    }
                    _ => Err("read-line requires a reader or no arguments for stdin".to_string()),
                }
            }
        })),
    );

    env.set(
        "println".to_string(),
        Value::Function(Function::Native(|args| {
            if args.is_empty() {
                println!();
                Ok(Value::Nil)
            } else {
                let output = args
                    .iter()
                    .map(|arg| match arg {
                        Value::Str(s) => s.clone(),
                        other => format!("{}", other),
                    })
                    .collect::<Vec<String>>()
                    .join(" ");
                println!("{}", output);
                Ok(Value::Nil)
            }
        })),
    );

    env.set(
        "printf".to_string(),
        Value::Function(Function::Native(|args| {
            if args.is_empty() {
                return Err("printf requires at least 1 argument".to_string());
            }
            
            let format_str = match &args[0] {
                Value::Str(s) => s.clone(),
                other => format!("{}", other),
            };
            
            // Simple printf implementation - just replace %s with arguments
            let mut result = format_str.clone();
            for (i, arg) in args.iter().skip(1).enumerate() {
                let placeholder = format!("%{}", i + 1);
                let value = match arg {
                    Value::Str(s) => s.clone(),
                    other => format!("{}", other),
                };
                result = result.replace(&placeholder, &value);
            }
            
            // Also support %s for sequential replacement
            let mut parts = result.split("%s");
            let mut output = String::new();
            let mut arg_index = 1;
            
            output.push_str(parts.next().unwrap_or(""));
            for part in parts {
                if arg_index < args.len() {
                    let value = match &args[arg_index] {
                        Value::Str(s) => s.clone(),
                        other => format!("{}", other),
                    };
                    output.push_str(&value);
                    arg_index += 1;
                } else {
                    output.push_str("%s");
                }
                output.push_str(part);
            }
            
            print!("{}", output);
            Ok(Value::Nil)
        })),
    );

    // Essential helper functions as native functions to avoid closure overhead
    env.set(
        "inc".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("inc requires exactly 1 argument".to_string());
            }
            if let Value::Number(n) = &args[0] {
                Ok(Value::Number(n + 1.0))
            } else {
                Err("inc requires a number".to_string())
            }
        })),
    );

    env.set(
        "dec".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("dec requires exactly 1 argument".to_string());
            }
            if let Value::Number(n) = &args[0] {
                Ok(Value::Number(n - 1.0))
            } else {
                Err("dec requires a number".to_string())
            }
        })),
    );

    env.set(
        "abs".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("abs requires exactly 1 argument".to_string());
            }
            if let Value::Number(n) = &args[0] {
                Ok(Value::Number(n.abs()))
            } else {
                Err("abs requires a number".to_string())
            }
        })),
    );

    env.set(
        "identity".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("identity requires exactly 1 argument".to_string());
            }
            Ok(args[0].clone())
        })),
    );

    env.set(
        "nil?".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("nil? requires exactly 1 argument".to_string());
            }
            Ok(Value::Bool(args[0] == Value::Nil))
        })),
    );

    env.set(
        "zero?".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("zero? requires exactly 1 argument".to_string());
            }
            if let Value::Number(n) = &args[0] {
                Ok(Value::Bool(*n == 0.0))
            } else {
                Err("zero? requires a number".to_string())
            }
        })),
    );

    env.set(
        "pos?".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("pos? requires exactly 1 argument".to_string());
            }
            if let Value::Number(n) = &args[0] {
                Ok(Value::Bool(*n > 0.0))
            } else {
                Err("pos? requires a number".to_string())
            }
        })),
    );

    env.set(
        "neg?".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("neg? requires exactly 1 argument".to_string());
            }
            if let Value::Number(n) = &args[0] {
                Ok(Value::Bool(*n < 0.0))
            } else {
                Err("neg? requires a number".to_string())
            }
        })),
    );

    env.set(
        "even?".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("even? requires exactly 1 argument".to_string());
            }
            if let Value::Number(n) = &args[0] {
                if n.fract() != 0.0 {
                    return Err("even? requires an integer".to_string());
                }
                Ok(Value::Bool((*n as i64) % 2 == 0))
            } else {
                Err("even? requires a number".to_string())
            }
        })),
    );

    env.set(
        "odd?".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("odd? requires exactly 1 argument".to_string());
            }
            if let Value::Number(n) = &args[0] {
                if n.fract() != 0.0 {
                    return Err("odd? requires an integer".to_string());
                }
                Ok(Value::Bool((*n as i64) % 2 != 0))
            } else {
                Err("odd? requires a number".to_string())
            }
        })),
    );

    // Add negative? as alias for neg?
    env.set(
        "negative?".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("negative? requires exactly 1 argument".to_string());
            }
            match &args[0] {
                Value::Number(n) => Ok(Value::Bool(*n < 0.0)),
                _ => Err("negative? requires a number".to_string())
            }
        })),
    );

    // Min and max functions
    env.set(
        "min".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() < 2 {
                return Err("min requires at least 2 arguments".to_string());
            }
            let mut result = match &args[0] {
                Value::Number(n) => *n,
                _ => return Err("min requires numbers".to_string()),
            };
            for arg in &args[1..] {
                if let Value::Number(n) = arg {
                    if *n < result {
                        result = *n;
                    }
                } else {
                    return Err("min requires numbers".to_string());
                }
            }
            Ok(Value::Number(result))
        })),
    );

    env.set(
        "max".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() < 2 {
                return Err("max requires at least 2 arguments".to_string());
            }
            let mut result = match &args[0] {
                Value::Number(n) => *n,
                _ => return Err("max requires numbers".to_string()),
            };
            for arg in &args[1..] {
                if let Value::Number(n) = arg {
                    if *n > result {
                        result = *n;
                    }
                } else {
                    return Err("max requires numbers".to_string());
                }
            }
            Ok(Value::Number(result))
        })),
    );

    // Additional predicate functions
    env.set(
        "true?".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("true? requires exactly 1 argument".to_string());
            }
            Ok(Value::Bool(args[0] == Value::Bool(true)))
        })),
    );

    env.set(
        "false?".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("false? requires exactly 1 argument".to_string());
            }
            Ok(Value::Bool(args[0] == Value::Bool(false)))
        })),
    );

    env.set(
        "some?".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("some? requires exactly 1 argument".to_string());
            }
            Ok(Value::Bool(args[0] != Value::Nil))
        })),
    );

    // constantly function - returns a function that always returns the given value
    env.set(
        "constantly".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("constantly requires exactly 1 argument".to_string());
            }
            let value = args[0].clone();
            // Return a function that ignores its arguments and returns the captured value
            Ok(Value::Function(Function::UserDefined {
                params: vec!["_".to_string()], // dummy parameter
                body: Box::new(value),
                env: Env::new(), // empty environment since we just return the literal value
            }))
        })),
    );

    // time function - executes a function and returns its result
    env.set(
        "time".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("time requires exactly 1 argument".to_string());
            }
            match &args[0] {
                Value::Function(Function::Native(f)) => f(&[]),
                Value::Function(Function::UserDefined { params, body, env: func_env }) => {
                    if !params.is_empty() {
                        return Err("time requires a function with no parameters".to_string());
                    }
                    // Execute the function body in its captured environment
                    let mut exec_env = func_env.clone();
                    eval(body, &mut exec_env)
                }
                _ => Err("time requires a function".to_string()),
            }
        })),
    );

    // when macro - (when condition body...) expands to (if condition (do body...) nil)
    env.set(
        "when".to_string(),
        Value::Function(Function::Macro {
            params: vec!["condition".to_string(), "body".to_string()],
            body: Box::new(Value::List(vec![
                Value::Symbol("if".to_string()),
                Value::Symbol("condition".to_string()),
                Value::Symbol("body".to_string()),
                Value::Nil,
            ])),
            env: env.clone(),
        }),
    );

    // unless macro - (unless condition body...) expands to (if condition nil (do body...))
    env.set(
        "unless".to_string(),
        Value::Function(Function::Macro {
            params: vec!["condition".to_string(), "body".to_string()],
            body: Box::new(Value::List(vec![
                Value::Symbol("if".to_string()),
                Value::Symbol("condition".to_string()),
                Value::Nil,
                Value::Symbol("body".to_string()),
            ])),
            env: env.clone(),
        }),
    );

    // make-timer function - returns a function that returns elapsed time since creation
    env.set(
        "make-timer".to_string(),
        Value::Function(Function::Native(|args| {
            if !args.is_empty() {
                return Err("make-timer takes no arguments".to_string());
            }
            use std::time::{SystemTime, UNIX_EPOCH};
            let start_time = SystemTime::now().duration_since(UNIX_EPOCH)
                .map_err(|_| "Failed to get system time".to_string())?
                .as_millis() as f64;
            
            // Return a function that returns elapsed time
            Ok(Value::Function(Function::UserDefined {
                params: vec![],
                body: Box::new(Value::List(vec![
                    Value::Symbol("-".to_string()),
                    Value::List(vec![Value::Symbol("now-ms".to_string())]),
                    Value::Number(start_time),
                ])),
                env: create_default_env(), // Need access to built-in functions
            }))
        })),
    );

    // Mathematical functions
    env.set(
        "square".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("square requires exactly 1 argument".to_string());
            }
            if let Value::Number(n) = &args[0] {
                Ok(Value::Number(n * n))
            } else {
                Err("square requires a number".to_string())
            }
        })),
    );

    env.set(
        "cube".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("cube requires exactly 1 argument".to_string());
            }
            if let Value::Number(n) = &args[0] {
                Ok(Value::Number(n * n * n))
            } else {
                Err("cube requires a number".to_string())
            }
        })),
    );

    // Essential functional programming primitives
    
    // apply - apply function to collection of arguments
    env.set(
        "apply".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 2 {
                return Err("apply requires exactly 2 arguments".to_string());
            }
            
            let func = &args[0];
            let arg_list = &args[1];
            
            // Extract arguments from list/vector
            let call_args = match arg_list {
                Value::List(items) => items.clone(),
                Value::Vector(items) => items.clone(),
                Value::Nil => vec![],
                _ => return Err("apply requires a list or vector as second argument".to_string()),
            };
            
            // Call the function with the arguments
            match func {
                Value::Function(Function::Native(f)) => f(&call_args),
                Value::Function(Function::UserDefined { params, body, env: func_env }) => {
                    if params.len() != call_args.len() {
                        return Err(format!("Function expects {} arguments, got {}", params.len(), call_args.len()));
                    }
                    
                    let mut exec_env = func_env.clone();
                    for (param, arg) in params.iter().zip(call_args.iter()) {
                        exec_env.set(param.clone(), arg.clone());
                    }
                    eval(body, &mut exec_env)
                }
                Value::Function(Function::Macro { .. }) => {
                    Err("Cannot apply macro (use macroexpand instead)".to_string())
                }
                _ => Err("First argument to apply must be a function".to_string()),
            }
        })),
    );
    
    // concat - concatenate collections
    env.set(
        "concat".to_string(),
        Value::Function(Function::Native(|args| {
            let mut result = Vec::new();
            
            for arg in args {
                match arg {
                    Value::List(items) => result.extend(items.clone()),
                    Value::Vector(items) => result.extend(items.clone()),
                    Value::Nil => {}, // nil contributes nothing
                    _ => return Err("concat requires lists, vectors, or nil".to_string()),
                }
            }
            
            Ok(Value::List(result))
        })),
    );
    
    // Type predicate functions
    env.set(
        "string?".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("string? requires exactly 1 argument".to_string());
            }
            Ok(Value::Bool(matches!(args[0], Value::Str(_))))
        })),
    );
    
    env.set(
        "number?".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("number? requires exactly 1 argument".to_string());
            }
            Ok(Value::Bool(matches!(args[0], Value::Number(_))))
        })),
    );
    
    env.set(
        "vector?".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("vector? requires exactly 1 argument".to_string());
            }
            Ok(Value::Bool(matches!(args[0], Value::Vector(_))))
        })),
    );
    
    env.set(
        "list?".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("list? requires exactly 1 argument".to_string());
            }
            Ok(Value::Bool(matches!(args[0], Value::List(_))))
        })),
    );
    
    env.set(
        "map?".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("map? requires exactly 1 argument".to_string());
            }
            Ok(Value::Bool(matches!(args[0], Value::Map(_))))
        })),
    );
    
    // empty? - check if collection is empty
    env.set(
        "empty?".to_string(),
        Value::Function(Function::Native(|args| {
            if args.len() != 1 {
                return Err("empty? requires exactly 1 argument".to_string());
            }
            let is_empty = match &args[0] {
                Value::List(items) => items.is_empty(),
                Value::Vector(items) => items.is_empty(),
                Value::Str(s) => s.is_empty(),
                Value::Nil => true,
                _ => false,
            };
            Ok(Value::Bool(is_empty))
        })),
    );

    env
}

fn eval_ns(list: &[Value], env: &mut Env) -> Result<Value, String> {
    if list.len() != 2 {
        return Err("ns requires exactly 1 argument".to_string());
    }

    match &list[1] {
        Value::Symbol(ns_name) => {
            env.set_namespace(ns_name.clone());
            Ok(Value::Symbol(ns_name.clone()))
        }
        _ => Err("ns requires a symbol argument".to_string()),
    }
}

fn eval_require(list: &[Value], env: &mut Env) -> Result<Value, String> {
    if list.len() != 2 {
        return Err("require requires exactly 1 argument".to_string());
    }

    match &list[1] {
        // Handle [namespace :as alias] form
        Value::Vector(vec) if vec.len() == 3 => {
            if let (Value::Symbol(ns_name), Value::Keyword(as_kw), Value::Symbol(alias)) = 
                (&vec[0], &vec[1], &vec[2]) {
                if as_kw == "as" {
                    // Load the namespace first
                    load_namespace(ns_name, env)?;
                    // Add the alias
                    env.add_alias(alias.clone(), ns_name.clone());
                    return Ok(Value::Symbol(ns_name.clone()));
                }
            }
            Err("require vector form expects [namespace :as alias]".to_string())
        }
        // Handle quoted symbol like '(quote my.namespace)
        Value::List(quoted) if quoted.len() == 2 => {
            if let (Value::Symbol(quote), Value::Symbol(ns_name)) = (&quoted[0], &quoted[1]) {
                if quote == "quote" {
                    return load_namespace(ns_name, env);
                }
            }
            Err("require expects a quoted symbol".to_string())
        }
        // Handle quote shorthand 'my.namespace
        Value::Symbol(ns_name) if list[1].to_string().starts_with('\'') => {
            let ns_name = ns_name.strip_prefix('\'').unwrap_or(ns_name);
            load_namespace(ns_name, env)
        }
        _ => Err("require expects 'namespace or [namespace :as alias]".to_string()),
    }
}

fn load_namespace(ns_name: &str, env: &mut Env) -> Result<Value, String> {
    // Check if already loaded
    if env.is_namespace_loaded(ns_name) {
        return Ok(Value::Symbol(ns_name.to_string()));
    }

    // Convert namespace name to file path
    // my.namespace -> std/my/namespace.lisp
    let file_path = if ns_name.starts_with("core.") {
        format!("std/{}.lisp", ns_name.replace('.', "/"))
    } else {
        format!("std/{}.lisp", ns_name.replace('.', "/"))
    };

    // Save current namespace
    let _current_ns = env.get_namespace().to_string();

    // Load the file WITHOUT setting namespace (avoid expensive operations)
    let result = load_namespace_file(&file_path, env);

    // Don't change namespace during loading for performance

    match result {
        Ok(_) => {
            env.add_loaded_namespace(ns_name.to_string());
            Ok(Value::Symbol(ns_name.to_string()))
        }
        Err(e) => Err(format!("Failed to load namespace '{}': {}", ns_name, e)),
    }
}

// Optimized loading function - minimal overhead
fn load_form(form: &Value, env: &mut Env) -> Result<Value, String> {
    match form {
        Value::List(list) if !list.is_empty() => {
            match &list[0] {
                Value::Symbol(name) => match name.as_str() {
                    // For ns, just note the namespace - don't evaluate  
                    "ns" => Ok(Value::Nil),
                    
                    // For defn, create function stub without cloning env
                    "defn" => {
                        if list.len() != 4 {
                            return Err("defn requires exactly 3 arguments".to_string());
                        }
                        if let Value::Symbol(fname) = &list[1] {
                            if let Value::Vector(params) = &list[2] {
                                let mut param_names = Vec::new();
                                for param in params {
                                    if let Value::Symbol(pname) = param {
                                        param_names.push(pname.clone());
                                    } else {
                                        return Err("Function parameters must be symbols".to_string());
                                    }
                                }
                                
                                // Create function without expensive env clone
                                // Only capture minimal environment needed
                                let func = Value::Function(Function::UserDefined {
                                    params: param_names,
                                    body: Box::new(list[3].clone()),
                                    env: env.clone(),
                                });
                                
                                env.set_namespaced(fname.clone(), func.clone());
                                Ok(func)
                            } else {
                                Err("Function parameters must be a vector".to_string())
                            }
                        } else {
                            Err("First argument to defn must be a symbol".to_string())
                        }
                    }
                    
                    // For defmacro, create macro stub  
                    "defmacro" => {
                        if list.len() != 4 {
                            return Err("defmacro requires exactly 3 arguments".to_string());
                        }
                        if let Value::Symbol(mname) = &list[1] {
                            if let Value::Vector(params) = &list[2] {
                                let mut param_names = Vec::new();
                                for param in params {
                                    if let Value::Symbol(pname) = param {
                                        param_names.push(pname.clone());
                                    } else {
                                        return Err("Macro parameters must be symbols".to_string());
                                    }
                                }
                                
                                // Create macro function
                                let macro_fn = Value::Function(Function::Macro {
                                    params: param_names,
                                    body: Box::new(list[3].clone()),
                                    env: env.clone(),
                                });
                                
                                env.set_namespaced(mname.clone(), macro_fn.clone());
                                Ok(macro_fn)
                            } else {
                                Err("Macro parameters must be a vector".to_string())
                            }
                        } else {
                            Err("First argument to defmacro must be a symbol".to_string())
                        }
                    }
                    
                    // For def, only handle simple constants, skip complex expressions
                    "def" => {
                        if list.len() != 3 {
                            return Err("def requires exactly 2 arguments".to_string());
                        }
                        if let Value::Symbol(name) = &list[1] {
                            // Only evaluate simple literal values
                            match &list[2] {
                                Value::Number(_) | Value::Str(_) | Value::Bool(_) | Value::Nil => {
                                    env.set_namespaced(name.clone(), list[2].clone());
                                    Ok(list[2].clone())
                                }
                                _ => {
                                    // For complex expressions, defer evaluation
                                    env.set_namespaced(name.clone(), Value::Uninitialized);
                                    Ok(Value::Nil)
                                }
                            }
                        } else {
                            Err("First argument to def must be a symbol".to_string())
                        }
                    }
                    
                    // Skip everything else during module loading
                    _ => Ok(Value::Nil),
                },
                _ => Ok(Value::Nil),
            }
        }
        _ => Ok(Value::Nil),
    }
}

// Hybrid fast loading: create functions but with minimal env
fn load_form_hybrid(form: &Value, env: &mut Env) -> Result<Value, String> {
    match form {
        Value::List(list) if !list.is_empty() => {
            match &list[0] {
                Value::Symbol(name) => match name.as_str() {
                    "ns" => Ok(Value::Nil),
                    "defn" => {
                        if list.len() != 4 {
                            return Err("defn requires exactly 3 arguments".to_string());
                        }
                        if let Value::Symbol(fname) = &list[1] {
                            if let Value::Vector(params) = &list[2] {
                                let mut param_names = Vec::new();
                                for param in params {
                                    if let Value::Symbol(pname) = param {
                                        param_names.push(pname.clone());
                                    } else {
                                        return Err("Function parameters must be symbols".to_string());
                                    }
                                }
                                
                                // Create function with VERY minimal environment
                                // Only copy essential global functions, not the entire namespace
                                let mut minimal_env = Env::new();
                                
                                // Copy essential functions for module functions
                                let essential_funcs = [
                                    "+", "-", "*", "/", "=", "<", ">", "<=", ">=", "not=",
                                    "first", "rest", "cons", "list", "list?", "nil?", "empty?",
                                    "if", "do", "and", "or", "not", "true?", "false?",
                                    "print", "str", "count", "concat", "vector?", "symbol?", "number?"
                                ];
                                for func_name in &essential_funcs {
                                    if let Some(func_val) = env.get(func_name) {
                                        minimal_env.set(func_name.to_string(), func_val);
                                    }
                                }
                                
                                let func = Value::Function(Function::UserDefined {
                                    params: param_names,
                                    body: Box::new(list[3].clone()),
                                    env: minimal_env,
                                });
                                
                                env.set_namespaced(fname.clone(), func.clone());
                                Ok(func)
                            } else {
                                Err("Function parameters must be a vector".to_string())
                            }
                        } else {
                            Err("First argument to defn must be a symbol".to_string())
                        }
                    }
                    "defmacro" => {
                        if list.len() != 4 {
                            return Err("defmacro requires exactly 3 arguments".to_string());
                        }
                        if let Value::Symbol(mname) = &list[1] {
                            if let Value::Vector(params) = &list[2] {
                                let mut param_names = Vec::new();
                                for param in params {
                                    if let Value::Symbol(pname) = param {
                                        param_names.push(pname.clone());
                                    } else {
                                        return Err("Macro parameters must be symbols".to_string());
                                    }
                                }
                                
                                let macro_fn = Value::Function(Function::Macro {
                                    params: param_names,
                                    body: Box::new(list[3].clone()),
                                    env: env.clone(), // Macros need full environment for type checking functions
                                });
                                
                                env.set_namespaced(mname.clone(), macro_fn.clone());
                                Ok(macro_fn)
                            } else {
                                Err("Macro parameters must be a vector".to_string())
                            }
                        } else {
                            Err("First argument to defmacro must be a symbol".to_string())
                        }
                    }
                    "def" => {
                        // Only handle simple literal values to avoid evaluation
                        if list.len() != 3 {
                            return Err("def requires exactly 2 arguments".to_string());
                        }
                        if let Value::Symbol(name) = &list[1] {
                            match &list[2] {
                                Value::Number(_) | Value::Str(_) | Value::Bool(_) | Value::Nil => {
                                    env.set_namespaced(name.clone(), list[2].clone());
                                    Ok(list[2].clone())
                                }
                                _ => {
                                    // Skip complex def expressions during loading
                                    Ok(Value::Nil)
                                }
                            }
                        } else {
                            Err("First argument to def must be a symbol".to_string())
                        }
                    }
                    _ => Ok(Value::Nil),
                },
                _ => Ok(Value::Nil),
            }
        }
        _ => Ok(Value::Nil),
    }
}

fn load_namespace_file(file_path: &str, env: &mut Env) -> Result<Value, String> {
    // Read the file
    let content = match std::fs::read_to_string(file_path) {
        Ok(content) => content,
        Err(e) => return Err(format!("Failed to read file '{}': {}", file_path, e)),
    };

    // Parse all forms from the file
    use crate::reader::read_all_forms;
    
    let forms = match read_all_forms(&content) {
        Ok(forms) => forms,
        Err(e) => return Err(format!("Parse error in '{}': {}", file_path, e)),
    };

    // Process forms with hybrid fast loading
    let mut last_result = Value::Nil;
    for form in forms {
        match load_form_hybrid(&form, env) {
            Ok(result) => last_result = result,
            Err(e) => return Err(format!("Error loading form in '{}': {}", file_path, e)),
        }
    }

    Ok(last_result)
}

pub fn macroexpand(expr: &Value, env: &Env) -> Result<Value, String> {
    if let Value::List(list) = expr {
        if !list.is_empty() {
            if let Value::Symbol(name) = &list[0] {
                if let Some(value) = env.get_with_namespaces(name) {
                    if let Value::Function(Function::Macro { params, body, env: macro_env }) = value {
                        return expand_macro_form(&params, &body, &list[1..], &macro_env);
                    }
                }
            }
        }
    }
    // Not a macro call, return as-is
    Ok(expr.clone())
}