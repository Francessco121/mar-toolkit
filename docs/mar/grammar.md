# Macro MAR Assembly Grammar

The grammar is defined in an [EBNF](https://en.wikipedia.org/wiki/Extended_Backus%E2%80%93Naur_form)-like form. See the [grammar defintion](#grammar-definition) section for more details.

## Grammar Definition

### Nonterminals
```
nonterminal = definition ;
```

### Symbols
```
x? - Zero or one occurrence of x.
x+ - One or more occurrences of x.
x* - Zero or more occurrences of x.

( ... ) - Grouping.
' ... ' - String terminal.

| - Alteration.
.. - No whitespace separator.
```

## Grammar
```dart
program             = ( statement ( NEWLINE statement? )* )? ;
statement           = line | macro ;

macro               = '#' .. macros ; 
macros              = include_macro | once_macro ;
include_macro       = INCLUDE STRING ;
once_macro          = ONCE ;

line                = ( line_content comment? ) | comment ;
line_content        = constant | section | labelable | label ;

constant            = IDENTIFIER EQU const_expression ;
section             = '.' IDENTIFIER ;
labelable           = label? ( instruction | directive ) ;
label               = IDENTIFIER ':' ;

directive           = org_directive | dw_directive ;

org_directive       = ORG const_expression ;

dw_directive        = DW dw_operand ( ',' dw_operand )*;
dw_operand          = dw_integer_operand | dw_string_operand ;
dw_integer_operand  = const_expression ( DUP '(' const_expression ')' )? ;
dw_string_operand   = STRING ;

instruction         = IDENTIFIER ( inst_operand ( ',' inst_operand )? )? ;
inst_operand        = immediate | memory | IDENTIFIER ;
immediate           = integer ;
memory              = '[' memory_value ( ( '-' | '+' ) memory_value )? ']' ;
memory_value        = integer | IDENTIFIER ;

const_expression    = const_value ( ( '-' | '+' ) const_value )* ;
const_value         = integer | IDENTIFIER | '(' const_expression ')' ;

integer             = INTEGER_BASE2 | INTEGER_BASE10 | INTEGER_BASE16 ;
comment             = ';' COMMENT_TEXT ;
```

## Named Terminals
Named terminals are described as regular expressions.

```javascript
COMMENT_TEXT    = /.*/ ;
DUP             = /dup/i ;
DW              = /dw/i ;
EQU             = /equ/i ;
IDENTIFIER      = /[_a-zA-Z][_a-zA-Z0-9]*/ ;
INCLUDE         = /include/i ;
INTEGER_BASE2   = /0b[01]+/ ;
INTEGER_BASE10  = /[0-9]+/ ;
INTEGER_BASE16  = /0x[0-9a-fA-F]+/ ;
NEWLINE         = /\r?\n/;
ONCE            = /once/i ;
ORG             = /org/i ;
STRING          = /"(?:.|\\b|\\n|\\r|\\t|\\0|\\\\|\\")*"/ ;
```