use crate::env::Env;
use crate::value::{Value, Function};
use std::collections::HashMap;

pub fn eval(expr: &Value, env: &mut Env) -> Result<Value, String> {
    match expr {
        Value::Number(_) | Value::Bool(_) | Value::Nil | Value::Str(_) | Value::Keyword(_) => {
            Ok(expr.clone())
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
                    "if" => eval_if(list, env),
                    "fn" => eval_fn(list, env),
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

fn eval_call(list: &[Value], env: &mut Env) -> Result<Value, String> {
    let mut evaluated = Vec::new();
    for item in list {
        evaluated.push(eval(item, env)?);
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
        }
    } else {
        Err(format!("Cannot call non-function: {:?}", evaluated[0]))
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

    env
}