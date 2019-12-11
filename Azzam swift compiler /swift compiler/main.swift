//
//  main.swift
//  swift compiler
//
//  Created by Azzam AL-Rashed on 11/12/2019.
//  Copyright © 2019 ficruty. All rights reserved.
//

import Foundation

var source_code = "while x { var int age = 10 } "

let tokenizer = Tokenizer(source_code: source_code, ignore_whitespace: true)
func tokenisation() {
    
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
}

func parsaration() {
    
    let parser = Parser(tokenizer: tokenizer)
    let syntax_tree = parser.parse()
    if parser.current_level != 0 {
        parser.syntax_error(token: parser.current_token!, message: "brackets error")
    }
    
    print(syntax_tree)
}


parsaration()
