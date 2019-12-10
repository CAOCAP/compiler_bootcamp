import UIKit

extension String {
    func safelyLimitedTo(length n: Int)->String {
        let c = self
        if (c.count <= n) { return self }
        return String( Array(c).prefix(upTo: n) )
    }
}

//Get nth character of a string in Swift programming language (return's String)
extension String {
    
  var length: Int {
    return count
  }

  subscript (i: Int) -> String {
    return self[i ..< i + 1]
  }

  func substring(fromIndex: Int) -> String {
    return self[min(fromIndex, length) ..< length]
  }

  func substring(toIndex: Int) -> String {
    return self[0 ..< max(0, toIndex)]
  }

  subscript (r: Range<Int>) -> String {
    let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                        upper: min(length, max(0, r.upperBound))))
    let start = index(startIndex, offsetBy: range.lowerBound)
    let end = index(start, offsetBy: range.upperBound - range.lowerBound)
    return String(self[start ..< end])
  }

}

// String Extension for grabbing a character at a specific position (return's Character)
extension String {
 
    func index(at position: Int, from start: Index? = nil) -> Index? {
        let startingIndex = start ?? startIndex
        return index(startingIndex, offsetBy: position, limitedBy: endIndex)
    }
 
    func character(at position: Int) -> Character? {
        guard position >= 0, let indexPosition = index(at: position) else {
            return nil
        }
        return self[indexPosition]
    }
}

class Token {
    var tid: String = ""
    var value: String = ""
    var category: String = ""
    var position: Int = 0
    var line_number: Int = 0
    
    init(tid: String, value: String, category: String, position: Int, line_number: Int) {
        self.tid = tid
        self.value = value
        self.category = category
        self.position = position
        self.line_number = line_number
    }
}

class Tokenizer {
    var position = -1
    var line_number = 1
    let step_keywords = ["def",
                         "var",
                         "int",
                         "float",
                         "string",
                         "boolean",
                         "if",
                         "else",
                         "for",
                         "while",
                         "end"]
    
    let punctuations = ["(" : "left_paren",
                        ")" : "right_paren",
                        "[" : "left_square",
                        "]" : "right_square",
                        ";" : "semicolon",
                        "," : "comma",
                        "{" : "left_curly",
                        "}" : "right_curly",]
    
    var source_code: String = ""
    var length: Int = 0
    
    init(source_code: String) {
        self.source_code = source_code
        self.length = source_code.count
    }
    
    func is_EOF() -> Bool { return !(self.position < self.length) }
    
    func is_peekable() -> Bool { return (self.position + 1) < self.length }
    
    func peek() -> Character {
        if self.is_peekable() { return self.source_code.character(at: self.position + 1)! } else { return "\0"}
    }
    
    func number_tokenizer() -> Token {
        var character = self.source_code.character(at: self.position)!
        let token = Token(tid: "integer_literal", value: String(character), category: "literal", position: self.position, line_number: self.line_number)
        self.position += 1
        while !is_EOF() {
            character = self.source_code.character(at: self.position)!
            if !character.isNumber {
                self.position -= 1
                break
            } else {
                token.value += String(character)
                self.position += 1
            }
        }
        return token
    }
    
    func identifier_tokenizer() -> Token {
        var character = self.source_code.character(at: self.position)!
        let token = Token(tid: "id", value: String(character), category: "identifier", position: self.position, line_number: self.line_number)
        self.position += 1
        while !is_EOF() {
            character = self.source_code.character(at: self.position)!
            if !(character.isNumber || character.isLetter || character == "_") {
                self.position -= 1
                break
            } else {
                token.value += String(character)
                self.position += 1
            }
        }
        
        if self.step_keywords.contains(token.value) {
            token.category = "keyword"
            token.tid = token.value + "_keyword"
            return token
        }
        return token
    }
    
    func comment_tokenizer() -> Token {
        var character = self.source_code.character(at: self.position)!
        let token = Token(tid: "comment", value: String(character), category: "comment", position: self.position, line_number: self.line_number)
        self.position += 1
        while !is_EOF() {
            character = self.source_code.character(at: self.position)!
            if !character.isNewline {
                self.position -= 1
                break
            } else {
                token.value += String(character)
                self.position += 1
            }
        }
        return token
    }
    
    func whitespace_tokenizer() -> Token {
        var character = self.source_code.character(at: self.position)!
        let token = Token(tid: "whitespace", value: String(character), category: "whitespace", position: self.position, line_number: self.line_number)
        if character.isNewline { self.line_number += 1 }
        self.position += 1
        while !is_EOF() {
            character = self.source_code.character(at: self.position)!
            if !character.isWhitespace {
                self.position -= 1
                break
            } else {
                if !character.isNewline { self.line_number += 1 }
                token.value += String(character)
                self.position += 1
            }
        }
        return token
    }
    
    
    func plus_tokenizer() -> Token {
        let character = self.source_code.character(at: self.position)!
        let token = Token(tid: "plus", value: String(character), category: "operator", position: self.position, line_number: self.line_number)
        let peek_value = self.peek()
        if peek_value == "+" {
            self.position += 1
            token.tid += "_plus"
            token.value += self.source_code[self.position]
        } else if peek_value == "=" {
            self.position += 1
            token.tid += "_equals"
            token.value += self.source_code[self.position]
        }
        return token
    }
    
    func minus_tokenizer() -> Token {
        let character = self.source_code.character(at: self.position)!
        let token = Token(tid: "minus", value: String(character), category: "operator", position: self.position, line_number: self.line_number)
        let peek_value = self.peek()
        if peek_value == "-" {
            self.position += 1
            token.tid += "_minus"
            token.value += self.source_code[self.position]
        } else if peek_value == "=" {
            self.position += 1
            token.tid += "_equals"
            token.value += self.source_code[self.position]
        }
        return token
    }
    
    func equal_tokenizer() -> Token {
        let character = self.source_code.character(at: self.position)!
        let token = Token(tid: "assignment", value: String(character), category: "operator", position: self.position, line_number: self.line_number)
        if self.peek() == "=" {
            self.position += 1
            token.tid = "equal_equal"
            token.value += self.source_code[self.position]
        }
        return token
    }
    
    func punctuation_tokenizer() -> Token {
        let character = self.source_code.character(at: self.position)!
        let tid = self.punctuations[String(character)]!
        let token = Token(tid: tid, value: String(character), category: "punctuation", position: self.position, line_number: self.line_number)
        return token
    }
    
    func tokenize() -> Token {
        self.position += 1
        while !self.is_EOF(){
            let character = self.source_code.character(at: self.position)!
            if character.isNumber {
                return self.number_tokenizer()
            } else if character.isLetter || character == "_" {
                return self.identifier_tokenizer()
            } else if character.isWhitespace {
                return self.whitespace_tokenizer()
            } else if character == "#" {
                return self.comment_tokenizer()
            } else if character == "+" {
                return self.plus_tokenizer()
            } else if character == "-" {
                return self.minus_tokenizer()
            } else if character == "=" {
                return self.equal_tokenizer()
            } else if punctuations.keys.contains(String(character)) {
                return self.comment_tokenizer()
            } else {
                return Token(tid: "error", value: String(character), category: "error", position: self.position, line_number: self.line_number)
            }
        }
        self.position += 1
        return Token(tid: "EOF",value: "EOF", category: "EOF", position: self.position, line_number: self.line_number)
    }
    
}


var source_code = " var azzam = 10"
var tokenizer = Tokenizer(source_code: source_code)
var token = tokenizer.tokenize()

while token.category != "EOF" {
    
    print("tid:        " , token.tid ,
          "\nvalue:      ", "[\(token.value)]",
          "\ncategory:   ", token.category,
          "\nposition:   ", token.position,
          "\nline_number:", token.line_number,
          "\n-----------------------------"
          )
    token = tokenizer.tokenize()
}
