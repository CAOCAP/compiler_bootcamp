//
//  Parser.swift
//  swift compiler
//
//  Created by Azzam AL-Rashed on 11/12/2019.
//  Copyright © 2019 ficruty. All rights reserved.
//

import Foundation

class Node {
    //TODO: pass
}

class Statement: Node {
    //TODO: pass
}

//TODO: can BlockStatement inherit from statement rather than node?
class BlockStatement: Statement {
    //TODO: pass
}

class VarStatement: Statement {
    //statement: var datatype id = literal
    var token: Token
    var datatype: Token
    var identifier: Token
    var value: Token
    init(token: Token, datatype: Token, identifier: Token, value: Token) {
        self.token = token
        self.datatype = datatype
        self.identifier = identifier
        self.value = value
    }
    
}

//TODO: (ask if its  correct )
class LetStatement: Statement {
    //statement: let datatype id = literal
    var token: Token
    var datatype: Token
    var identifier: Token
    var value: Token
    init(token: Token, datatype: Token, identifier: Token, value: Token) {
        self.token = token
        self.datatype = datatype
        self.identifier = identifier
        self.value = value
    }
    
}

class PrintStatement: Statement {
    //statement: print literal
    var token: Token
    var literal: Token
    init(token: Token, literal: Token) {
        self.token = token
        self.literal = literal
    }
    
}

class WhileStatement: BlockStatement {
    //statement: while literal {statements}
    var token: Token
    var literal: Token
    var statements: [Statement]
    init(token: Token, literal: Token, statements: [Statement]) {
        self.token = token
        self.literal = literal
        self.statements = statements
    }
    
}

//TODO: (ask if its  correct )
class IfStatement: BlockStatement {
    //statement: if boolean {statements}
    var token: Token
    var literal: Token
    var statements: [Statement]
    init(token: Token, literal: Token, statements: [Statement]) {
        self.token = token
        self.literal = literal
        self.statements = statements
    }
    
}

class Parser {
    var tokenizer: Tokenizer
    var current_token: Token? = nil
    var current_level = 0
    
    init(tokenizer: Tokenizer) {
        self.tokenizer = tokenizer
    }
    
    func syntax_error(token: Token, message: String) {
        print("[Step(syntax error)]:" + message + ", " + "[\(token.value)]" + ", line number: " + String(token.line_number) + ", position: " + String(token.position))
    }
    
    func match(token_value: String) {
        self.current_token = self.tokenizer.tokenize()
        //go to the next token
        if self.current_token!.value != token_value {
            self.syntax_error(token: self.current_token!, message: "unexpected token")
        }
    }
    
    func var_parser() -> Statement {
        //follow this statement:  var datatype id = literal
        let var_token = self.current_token!
        self.current_token = self.tokenizer.tokenize()
        //go to the next token
        
        if !(self.current_token?.category == "keyword" && ["int", "float", "string", "boolean"].contains(self.current_token?.value)) {
            self.syntax_error(token: self.current_token!, message: "datatype expected")
        }
        
        let datatype_token = self.current_token!
        self.current_token = self.tokenizer.tokenize()
        //go to the next token
        
        if self.current_token?.category != "identifier" {
            self.syntax_error(token: self.current_token!, message: "identifier expected")
        }
        
        let identifier_token = self.current_token!
        self.match(token_value: "=")
        self.current_token = self.tokenizer.tokenize()
        //go to the next token
        
        if self.current_token!.category != "literal" {
            self.syntax_error(token: self.current_token!,message: "literal expected")
        }
        
        let literal_token = self.current_token!
        
        return VarStatement(token: var_token , datatype: datatype_token, identifier: identifier_token, value: literal_token)
    }
    
    func let_parser() -> Statement {
        //follow this statement:  let datatype id = literal
        let let_token = self.current_token!
        self.current_token = self.tokenizer.tokenize()
        //go to the next token
        
        if !(self.current_token?.category == "keyword" && ["int", "float", "string", "boolean"].contains(self.current_token?.value)) {
            self.syntax_error(token: self.current_token!, message: "datatype expected")
        }
        
        let datatype_token = self.current_token!
        self.current_token = self.tokenizer.tokenize()
        //go to the next token
        
        if self.current_token?.category != "identifier" {
            self.syntax_error(token: self.current_token!, message: "identifier expected")
        }
        
        let identifier_token = self.current_token!
        self.match(token_value: "=")
        self.current_token = self.tokenizer.tokenize()
        //go to the next token
        
        if self.current_token!.category != "literal" {
            self.syntax_error(token: self.current_token!,message: "literal expected")
        }
        
        let literal_token = self.current_token!
        
        return LetStatement(token: let_token , datatype: datatype_token, identifier: identifier_token, value: literal_token)
    }
    
    func print_parser() -> Statement {
        //follow this statement:  print literal
        let print_token = self.current_token!
        self.current_token = self.tokenizer.tokenize()
        //go to the next token
        
        if self.current_token!.category != "literal" {
            self.syntax_error(token: self.current_token!, message: "literal expected")
        }
        return PrintStatement(token: print_token, literal: self.current_token!)
    }
    
    func while_parser() -> Statement {
        //follow this statement:  while literal {statements}
        let while_token = self.current_token!
        self.current_token = self.tokenizer.tokenize()
        //go to the next token
        
        if self.current_token!.category != "literal" {
            self.syntax_error(token: self.current_token!, message: "literal expected")
        }
        
        let literal_token = self.current_token!
        
        self.match(token_value: "{")
        self.current_level += 1
        let statements = self.parse()
        
        return WhileStatement(token: while_token, literal: literal_token, statements: statements)
    }
    
    func if_parser() -> Statement {
        //follow this statement:  if boolean {statements}
        let if_token = self.current_token!
        self.current_token = self.tokenizer.tokenize()
        //go to the next token
        
        if self.current_token!.category != "literal" {
            self.syntax_error(token: self.current_token!, message: "literal expected")
        }
        
        let literal_token = self.current_token!
        
        self.match(token_value: "{")
        self.current_level += 1
        let statements = self.parse()
        
        return IfStatement(token: if_token, literal: literal_token, statements: statements)
    }
    
    func parse() -> [Statement] {
        var statements = [Statement]()
        self.current_token = self.tokenizer.tokenize()
        //go to the next token
        
        while self.current_token!.category != "EOF" {
            if self.current_token!.category == "keyword" {
                if self.current_token!.value == "var" {
                    statements.append(self.var_parser())
                } else if self.current_token!.value == "let" {
                    statements.append(self.let_parser())
                } else if self.current_token!.value == "print" {
                    statements.append(self.print_parser())
                } else if self.current_token!.value == "while" {
                    statements.append(self.while_parser())
                } else if self.current_token!.value == "if" {
                    statements.append(self.if_parser())
                }
            } else if self.current_token!.value == "}" {
                self.current_level -= 1
                return statements
            } else if self.current_token!.category == "comment" {
                //dont do any thing i.e skip ignore comment
            } else if self.current_token!.category == "whitespace"{
                //dont do any thing i.e skip ignore whitespace
            } else if self.current_token!.category == "error"{
               self.syntax_error(token: self.current_token!, message: "unexpected token")
            } else {
                self.syntax_error(token: self.current_token!, message: "unexpected token")
            }
            self.current_token = self.tokenizer.tokenize()
        }
        return statements
    }
    
    
}



