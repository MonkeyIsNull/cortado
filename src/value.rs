use std::collections::HashMap;
use std::fmt;
use std::io::{BufRead, Read, Write};
use std::sync::{Arc, Mutex};
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

#[derive(Clone)]
pub enum IOResource {
    Reader(Arc<Mutex<Box<dyn BufRead + Send>>>),
    Writer(Arc<Mutex<Box<dyn Write + Send>>>),
    InputStream(Arc<Mutex<Box<dyn Read + Send>>>),
    OutputStream(Arc<Mutex<Box<dyn Write + Send>>>),
}

impl std::fmt::Debug for IOResource {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            IOResource::Reader(_) => write!(f, "IOResource::Reader"),
            IOResource::Writer(_) => write!(f, "IOResource::Writer"),
            IOResource::InputStream(_) => write!(f, "IOResource::InputStream"),
            IOResource::OutputStream(_) => write!(f, "IOResource::OutputStream"),
        }
    }
}

impl PartialEq for IOResource {
    fn eq(&self, _other: &Self) -> bool {
        false // IO resources are never equal
    }
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
    IOResource(IOResource),
    Uninitialized,
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
            Value::IOResource(_) => {
                10u8.hash(state);
            }
            Value::Uninitialized => {
                11u8.hash(state);
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
            Value::IOResource(resource) => match resource {
                IOResource::Reader(_) => write!(f, "#<reader>"),
                IOResource::Writer(_) => write!(f, "#<writer>"),
                IOResource::InputStream(_) => write!(f, "#<input-stream>"),
                IOResource::OutputStream(_) => write!(f, "#<output-stream>"),
            },
            Value::Uninitialized => write!(f, "#<uninitialized>"),
        }
    }
}