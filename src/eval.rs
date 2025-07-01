use crate::env::Env;
use crate::value::{Value, Function};
use std::collections::HashMap;

pub fn eval(expr: &Value, env: &mut Env) -> Result<Value, String> {
    match expr {
        Value::Number(_) | Value::Bool(_) | Value::Nil | Value::Str(_) | Value::Keyword(_) => {
            Ok(expr.clone())
        }
        Value::Uninitialized => {
            Err("Cannot evaluate uninitialized value".to_string())
        }
        Value::Symbol(name) => env
            .get(name)
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
                    "load" => eval_load(list, env),
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
        env.set(name.clone(), value.clone());
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

fn eval_defn(list: &[Value], env: &mut Env) -> Result<Value, String> {
    if list.len() != 4 {
        return Err("defn requires exactly 3 arguments".to_string());
    }

    if let Value::Symbol(name) = &list[1] {
        let fn_value = eval_fn(&[
            Value::Symbol("fn".to_string()),
            list[2].clone(),
            list[3].clone(),
        ], env)?;
        
        env.set(name.clone(), fn_value.clone());
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
        
        env.set(name.clone(), macro_fn.clone());
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

    // Parse and evaluate each top-level form
    use crate::reader::read;
    
    let lines: Vec<&str> = content.lines().collect();
    let mut current_expr = String::new();
    let mut paren_count = 0;
    let mut last_result = Value::Nil;

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
                        Ok(result) => last_result = result,
                        Err(e) => return Err(format!("Error evaluating expression in '{}': {}", filename, e)),
                    }
                }
                Err(e) => return Err(format!("Parse error in '{}': {}", filename, e)),
            }
            current_expr.clear();
        }
    }

    Ok(last_result)
}

fn eval_call(list: &[Value], env: &mut Env) -> Result<Value, String> {
    // First check if it's a macro call
    if let Value::Symbol(name) = &list[0] {
        if let Some(value) = env.get(name) {
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

                let mut local_env = Env::with_parent(captured_env.clone());
                for (param, arg) in params.iter().zip(&evaluated[1..]) {
                    local_env.set(param.clone(), arg.clone());
                }

                eval(body, &mut local_env)
            }
            Function::Macro { .. } => {
                Err("Macros should be expanded before evaluation".to_string())
            }
        }
    } else {
        Err(format!("Cannot call non-function: {:?}", evaluated[0]))
    }
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

    // File I/O functions
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

    env
}

pub fn macroexpand(expr: &Value, env: &Env) -> Result<Value, String> {
    if let Value::List(list) = expr {
        if !list.is_empty() {
            if let Value::Symbol(name) = &list[0] {
                if let Some(value) = env.get(name) {
                    if let Value::Function(Function::Macro { params, body, env: macro_env }) = value {
                        return expand_macro(&params, &body, &list[1..], &macro_env);
                    }
                }
            }
        }
    }
    // Not a macro call, return as-is
    Ok(expr.clone())
}