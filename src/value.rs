use std::collections::HashMap;
use std::fmt;
use crate::env::Env;

#[derive(Debug, Clone, PartialEq)]
pub enum Function {
    Native(fn(&[Value]) -> Result<Value, String>),
    UserDefined {
        params: Vec<String>,
        body: Box<Value>,
        env: Env,
    },
    Macro {
        params: Vec<String>,
        body: Box<Value>,
        env: Env,
    },
}

#[derive(Debug, Clone, PartialEq)]
pub enum Value {
    Symbol(String),
    Number(f64),
    Bool(bool),
    Nil,
    Str(String),
    List(Vec<Value>),
    Vector(Vec<Value>),
    Map(HashMap<String, Value>),
    Keyword(String),
    Function(Function),
}

impl Eq for Value {}

impl std::hash::Hash for Value {
    fn hash<H: std::hash::Hasher>(&self, state: &mut H) {
        match self {
            Value::Symbol(s) => {
                0u8.hash(state);
                s.hash(state);
            }
            Value::Number(n) => {
                1u8.hash(state);
                n.to_bits().hash(state);
            }
            Value::Bool(b) => {
                2u8.hash(state);
                b.hash(state);
            }
            Value::Nil => {
                3u8.hash(state);
            }
            Value::Str(s) => {
                4u8.hash(state);
                s.hash(state);
            }
            Value::List(v) => {
                5u8.hash(state);
                v.hash(state);
            }
            Value::Vector(v) => {
                6u8.hash(state);
                v.hash(state);
            }
            Value::Map(m) => {
                7u8.hash(state);
                let mut pairs: Vec<_> = m.iter().collect();
                pairs.sort_by_key(|(k, _)| k.as_str());
                for (k, v) in pairs {
                    k.hash(state);
                    v.hash(state);
                }
            }
            Value::Keyword(s) => {
                8u8.hash(state);
                s.hash(state);
            }
            Value::Function(_) => {
                9u8.hash(state);
            }
        }
    }
}

impl fmt::Display for Value {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        match self {
            Value::Symbol(s) => write!(f, "{}", s),
            Value::Number(n) => {
                if n.fract() == 0.0 && n.abs() < 1e15 {
                    write!(f, "{:.0}", n)
                } else {
                    write!(f, "{}", n)
                }
            }
            Value::Bool(b) => write!(f, "{}", b),
            Value::Nil => write!(f, "nil"),
            Value::Str(s) => write!(f, "\"{}\"", s.replace('\\', "\\\\").replace('"', "\\\"")),
            Value::List(v) => {
                write!(f, "(")?;
                for (i, val) in v.iter().enumerate() {
                    if i > 0 {
                        write!(f, " ")?;
                    }
                    write!(f, "{}", val)?;
                }
                write!(f, ")")
            }
            Value::Vector(v) => {
                write!(f, "[")?;
                for (i, val) in v.iter().enumerate() {
                    if i > 0 {
                        write!(f, " ")?;
                    }
                    write!(f, "{}", val)?;
                }
                write!(f, "]")
            }
            Value::Map(m) => {
                write!(f, "{{")?;
                let mut first = true;
                for (k, v) in m {
                    if !first {
                        write!(f, " ")?;
                    }
                    first = false;
                    write!(f, "{} {}", k, v)?;
                }
                write!(f, "}}")
            }
            Value::Keyword(s) => write!(f, ":{}", s),
            Value::Function(func) => match func {
                Function::Native(_) => write!(f, "#<native-function>"),
                Function::UserDefined { params, .. } => {
                    write!(f, "#<function({})>", params.join(" "))
                }
                Function::Macro { params, .. } => {
                    write!(f, "#<macro({})>", params.join(" "))
                }
            },
        }
    }
}