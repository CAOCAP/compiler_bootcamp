
from step.tokenizer import *
from step.parser import *
#result = evaluate(expr)

step_keywords = ['let', 'var', 'int', 'float', 'string', 'boolean', 'if', 'else', 'for', 'while', 'end', 'print', 'def', 'return']
step_punctuations = {
      '(' : 'left_paren',
      ')' : 'right_paren',
      '[' : 'left_square',
      ']' : 'right_square',
      ';' : 'semicolon',
      ',' : 'comma',
      '{' : 'left_curly',
      '}' : 'right_curly',
      ':' : 'colon'
    }
source_code = ''

with open('examples/main.stp') as stp:
  source_code = stp.read(1024)

tokenizer = Tokenizer(source_code,step_keywords,step_punctuations, True)
parser = Parser(tokenizer)

syntax_tree = parser.parse()
if parser.current_level != 0:
  raise Exception('brackets error')

print(syntax_tree)