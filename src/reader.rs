use crate::value::Value;
use std::collections::HashMap;

#[derive(Debug, Clone, PartialEq)]
enum Token {
    LeftParen,
    RightParen,
    LeftBracket,
    RightBracket,
    LeftBrace,
    RightBrace,
    Symbol(String),
    Number(f64),
    Str(String),
    Keyword(String),
    Bool(bool),
    Nil,
}

fn tokenize(input: &str) -> Result<Vec<Token>, String> {
    let mut tokens = Vec::new();
    let chars: Vec<char> = input.chars().collect();
    let mut i = 0;

    while i < chars.len() {
        match chars[i] {
            ' ' | '\t' | '\n' | '\r' | ',' => {
                i += 1;
            }
            '(' => {
                tokens.push(Token::LeftParen);
                i += 1;
            }
            ')' => {
                tokens.push(Token::RightParen);
                i += 1;
            }
            '[' => {
                tokens.push(Token::LeftBracket);
                i += 1;
            }
            ']' => {
                tokens.push(Token::RightBracket);
                i += 1;
            }
            '{' => {
                tokens.push(Token::LeftBrace);
                i += 1;
            }
            '}' => {
                tokens.push(Token::RightBrace);
                i += 1;
            }
            '"' => {
                i += 1;
                let mut string = String::new();
                while i < chars.len() && chars[i] != '"' {
                    if chars[i] == '\\' && i + 1 < chars.len() {
                        i += 1;
                        match chars[i] {
                            'n' => string.push('\n'),
                            'r' => string.push('\r'),
                            't' => string.push('\t'),
                            '\\' => string.push('\\'),
                            '"' => string.push('"'),
                            _ => {
                                string.push('\\');
                                string.push(chars[i]);
                            }
                        }
                    } else {
                        string.push(chars[i]);
                    }
                    i += 1;
                }
                if i >= chars.len() {
                    return Err("Unterminated string".to_string());
                }
                i += 1;
                tokens.push(Token::Str(string));
            }
            ':' => {
                i += 1;
                let mut keyword = String::new();
                while i < chars.len() && is_symbol_char(chars[i]) {
                    keyword.push(chars[i]);
                    i += 1;
                }
                if keyword.is_empty() {
                    return Err("Invalid keyword".to_string());
                }
                tokens.push(Token::Keyword(keyword));
            }
            ';' => {
                while i < chars.len() && chars[i] != '\n' {
                    i += 1;
                }
            }
            _ => {
                if chars[i].is_numeric() || (chars[i] == '-' && i + 1 < chars.len() && chars[i + 1].is_numeric()) {
                    let mut num_str = String::new();
                    if chars[i] == '-' {
                        num_str.push('-');
                        i += 1;
                    }
                    while i < chars.len() && (chars[i].is_numeric() || chars[i] == '.') {
                        num_str.push(chars[i]);
                        i += 1;
                    }
                    match num_str.parse::<f64>() {
                        Ok(n) => tokens.push(Token::Number(n)),
                        Err(_) => return Err(format!("Invalid number: {}", num_str)),
                    }
                } else if is_symbol_start(chars[i]) {
                    let mut symbol = String::new();
                    while i < chars.len() && is_symbol_char(chars[i]) {
                        symbol.push(chars[i]);
                        i += 1;
                    }
                    match symbol.as_str() {
                        "true" => tokens.push(Token::Bool(true)),
                        "false" => tokens.push(Token::Bool(false)),
                        "nil" => tokens.push(Token::Nil),
                        _ => tokens.push(Token::Symbol(symbol)),
                    }
                } else {
                    return Err(format!("Unexpected character: {}", chars[i]));
                }
            }
        }
    }

    Ok(tokens)
}

fn is_symbol_start(c: char) -> bool {
    c.is_alphabetic() || "+-*/<>=!?&%|_".contains(c)
}

fn is_symbol_char(c: char) -> bool {
    c.is_alphanumeric() || "+-*/<>=!?&%|_-.".contains(c)
}

struct Parser {
    tokens: Vec<Token>,
    pos: usize,
}

impl Parser {
    fn new(tokens: Vec<Token>) -> Self {
        Parser { tokens, pos: 0 }
    }

    fn parse(&mut self) -> Result<Value, String> {
        if self.pos >= self.tokens.len() {
            return Err("Unexpected end of input".to_string());
        }

        match &self.tokens[self.pos].clone() {
            Token::LeftParen => self.parse_list(),
            Token::LeftBracket => self.parse_vector(),
            Token::LeftBrace => self.parse_map(),
            Token::Symbol(s) => {
                self.pos += 1;
                Ok(Value::Symbol(s.clone()))
            }
            Token::Number(n) => {
                self.pos += 1;
                Ok(Value::Number(*n))
            }
            Token::Str(s) => {
                self.pos += 1;
                Ok(Value::Str(s.clone()))
            }
            Token::Keyword(k) => {
                self.pos += 1;
                Ok(Value::Keyword(k.clone()))
            }
            Token::Bool(b) => {
                self.pos += 1;
                Ok(Value::Bool(*b))
            }
            Token::Nil => {
                self.pos += 1;
                Ok(Value::Nil)
            }
            _ => Err(format!("Unexpected token: {:?}", self.tokens[self.pos])),
        }
    }

    fn parse_list(&mut self) -> Result<Value, String> {
        self.pos += 1;
        let mut items = Vec::new();

        while self.pos < self.tokens.len() {
            match &self.tokens[self.pos] {
                Token::RightParen => {
                    self.pos += 1;
                    return Ok(Value::List(items));
                }
                _ => items.push(self.parse()?),
            }
        }

        Err("Unterminated list".to_string())
    }

    fn parse_vector(&mut self) -> Result<Value, String> {
        self.pos += 1;
        let mut items = Vec::new();

        while self.pos < self.tokens.len() {
            match &self.tokens[self.pos] {
                Token::RightBracket => {
                    self.pos += 1;
                    return Ok(Value::Vector(items));
                }
                _ => items.push(self.parse()?),
            }
        }

        Err("Unterminated vector".to_string())
    }

    fn parse_map(&mut self) -> Result<Value, String> {
        self.pos += 1;
        let mut map = HashMap::new();

        while self.pos < self.tokens.len() {
            match &self.tokens[self.pos] {
                Token::RightBrace => {
                    self.pos += 1;
                    return Ok(Value::Map(map));
                }
                _ => {
                    let key = match self.parse()? {
                        Value::Keyword(k) => k,
                        Value::Str(s) => s,
                        _ => return Err("Map keys must be keywords or strings".to_string()),
                    };
                    
                    if self.pos >= self.tokens.len() {
                        return Err("Map missing value for key".to_string());
                    }
                    
                    let value = self.parse()?;
                    map.insert(key, value);
                }
            }
        }

        Err("Unterminated map".to_string())
    }
}

pub fn read(input: &str) -> Result<Value, String> {
    let tokens = tokenize(input)?;
    if tokens.is_empty() {
        return Err("Empty input".to_string());
    }
    
    let mut parser = Parser::new(tokens);
    let result = parser.parse()?;
    
    if parser.pos < parser.tokens.len() {
        return Err("Extra input after expression".to_string());
    }
    
    Ok(result)
}