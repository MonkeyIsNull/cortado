use crate::value::Value;
use std::collections::HashMap;

#[derive(Clone, Debug, PartialEq)]
pub struct Env {
    parent: Option<Box<Env>>,
    data: HashMap<String, Value>,
}

impl Env {
    pub fn new() -> Self {
        Env {
            parent: None,
            data: HashMap::new(),
        }
    }

    pub fn with_parent(parent: Env) -> Self {
        Env {
            parent: Some(Box::new(parent)),
            data: HashMap::new(),
        }
    }

    pub fn set(&mut self, name: String, val: Value) {
        self.data.insert(name, val);
    }

    pub fn get(&self, name: &str) -> Option<Value> {
        if let Some(val) = self.data.get(name) {
            Some(val.clone())
        } else if let Some(parent) = &self.parent {
            parent.get(name)
        } else {
            None
        }
    }

    pub fn update(&mut self, name: &str, val: Value) -> Result<(), String> {
        if self.data.contains_key(name) {
            self.data.insert(name.to_string(), val);
            Ok(())
        } else if let Some(parent) = &mut self.parent {
            parent.update(name, val)
        } else {
            Err(format!("Variable {} not found for update", name))
        }
    }
}