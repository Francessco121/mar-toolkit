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
```

## Grammar
```javascript
program             = line* ;
line                = ( constant | section | labelable )? comment? NEWLINE ;

constant            = LABEL EQU const_expression ;
section             = '.' MNEMONIC ;
labelable           = ( LABEL ':' )? ( instruction | directive ) ;

directive           = org_directive | dw_directive ;

org_directive       = ORG const_expression ;

dw_directive        = DW dw_operand ( ',' dw_operand )*;
dw_operand          = dw_integer_operand | dw_string_operand ;
dw_integer_operand  = const_expression ( DUP '(' const_expression ')' )? ;
dw_string_operand   = STRING ;

instruction         = MNEMONIC ( inst_operand ( ',' inst_operand )? )? ;
inst_operand        = immediate | register | memory ;
immediate           = integer ;
register            = MNEMONIC ;
memory              = '[' memory_value ( ( '-' | '+' ) memory_value )? ']' ;
memory_value        = integer | register | LABEL ;

const_expression    = const_value ( ( '-' | '+' ) const_value )* ;
const_value         = integer | LABEL ;

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
INTEGER_BASE2   = /0b[01]+/ ;
INTEGER_BASE10  = /[0-9]+/ ;
INTEGER_BASE16  = /0x[0-9a-fA-F]+/ ;
LABEL           = /[_a-zA-Z][_a-zA-Z0-9]*/ ;
MNEMONIC        = /[a-zA-Z]+/ ;
NEWLINE         = /\r?\n/;
ORG             = /org/i ;
STRING          = /(?:.|\\a|\\b|\\f|\\n|\\r|\\t|\\v|\\\\|\\")*/ ;
```