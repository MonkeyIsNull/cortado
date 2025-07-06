use crate::value::Value;
use std::collections::{HashMap, HashSet};

#[derive(Clone, Debug, PartialEq)]
pub struct Env {
    parent: Option<Box<Env>>,
    data: HashMap<String, Value>,
    current_namespace: String,
    loaded_namespaces: HashSet<String>,
    namespace_aliases: HashMap<String, String>, // alias -> full namespace mapping
}

impl Env {
    pub fn new() -> Self {
        Env {
            parent: None,
            data: HashMap::new(),
            current_namespace: "user".to_string(),
            loaded_namespaces: HashSet::new(),
            namespace_aliases: HashMap::new(),
        }
    }

    pub fn with_parent(parent: Env) -> Self {
        let current_namespace = parent.current_namespace.clone();
        let loaded_namespaces = parent.loaded_namespaces.clone();
        let namespace_aliases = parent.namespace_aliases.clone();
        
        Env {
            parent: Some(Box::new(parent)),
            data: HashMap::new(),
            current_namespace,
            loaded_namespaces,
            namespace_aliases,
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

    // Namespace management methods
    pub fn set_namespace(&mut self, ns: String) {
        self.current_namespace = ns;
    }

    pub fn get_namespace(&self) -> &str {
        &self.current_namespace
    }

    pub fn add_loaded_namespace(&mut self, ns: String) {
        self.loaded_namespaces.insert(ns);
    }

    pub fn is_namespace_loaded(&self, ns: &str) -> bool {
        self.loaded_namespaces.contains(ns)
    }

    // Set a namespaced symbol
    pub fn set_namespaced(&mut self, name: String, val: Value) {
        let qualified_name = if name.contains('/') {
            // Already qualified
            name
        } else {
            // Qualify with current namespace
            format!("{}/{}", self.current_namespace, name)
        };
        self.data.insert(qualified_name, val);
    }

    // Get with namespace resolution
    pub fn get_with_namespaces(&self, name: &str) -> Option<Value> {
        // If already qualified (contains '/'), look up directly
        if name.contains('/') {
            return self.get(name);
        }

        // Try current namespace first
        let qualified_name = format!("{}/{}", self.current_namespace, name);
        if let Some(val) = self.get(&qualified_name) {
            return Some(val);
        }

        // Try core namespace
        let core_name = format!("core/{}", name);
        if let Some(val) = self.get(&core_name) {
            return Some(val);
        }

        // Try user namespace
        let user_name = format!("user/{}", name);
        if let Some(val) = self.get(&user_name) {
            return Some(val);
        }

        // Fall back to unqualified lookup for built-ins
        self.get(name)
    }

    // Add a namespace alias
    pub fn add_alias(&mut self, alias: String, namespace: String) {
        self.namespace_aliases.insert(alias, namespace);
    }

    // Get the full namespace for an alias
    pub fn resolve_alias(&self, alias: &str) -> Option<&String> {
        if let Some(ns) = self.namespace_aliases.get(alias) {
            Some(ns)
        } else if let Some(parent) = &self.parent {
            parent.resolve_alias(alias)
        } else {
            None
        }
    }

    // Enhanced symbol resolution that handles aliases
    pub fn get_with_aliases(&self, name: &str) -> Option<Value> {
        // If name contains '/', check if the prefix is an alias
        if let Some(slash_pos) = name.find('/') {
            let (prefix, suffix) = name.split_at(slash_pos);
            let suffix = &suffix[1..]; // Remove the '/'
            
            // Check if prefix is an alias
            if let Some(full_ns) = self.resolve_alias(prefix) {
                let qualified_name = format!("{}/{}", full_ns, suffix);
                return self.get(&qualified_name);
            }
        }

        // Fall back to regular namespace resolution
        self.get_with_namespaces(name)
    }

    // Get all functions from a specific namespace
    pub fn get_namespace_functions(&self, namespace: &str) -> Vec<(String, Value)> {
        let mut functions = Vec::new();
        let prefix = format!("{}/", namespace);
        
        for (key, value) in &self.data {
            if key.starts_with(&prefix) {
                functions.push((key.clone(), value.clone()));
            }
        }
        
        // Also check parent environments
        if let Some(parent) = &self.parent {
            functions.extend(parent.get_namespace_functions(namespace));
        }
        
        functions
    }
}