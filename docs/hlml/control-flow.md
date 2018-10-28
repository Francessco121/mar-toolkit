[[← back]](./README.md)

# HLML Control Flow

## Contents
- [Branches](#branches)
    - [If/else](#ifelse-branching)
- [Loops](#loops)
    - [Infinite loop](#infinite-loop)
    - [While loop](#while-loop)
    - [Do-while loop](#do-while-loop)
    - [Special loop statements](#special-loop-statements)

## Branches

### If/else branching

#### Syntax
```c
if_statement:
'if' expression '{' ... '}' else_branch? ;

else_branch:
'else' ( '{' ... '}' ) | if_statement ;
```

#### Simple if statement
```rust
if true {
    // condition was true
}
```

#### If/else
```rust
if true {
    // condition was true
} else {
    // condition was false
}
```

#### If, else if, and else
```rust
let i: u16 = ...;

if i > 5 {
    // i is greater than 5
} else if i > 2 {
    // i is greater than 2 but less than or equal to 5
} else {
    // i is less than or equal to 2
}
```


## Loops

### Infinite loop

#### Syntax
```c
loop_statement:
'loop' '{' ... '}' ;
```

#### Example
```rust
// Loops until a break or return statement
loop {
    // ...
}
```

### While loop

#### Syntax
```c
while_statement:
'while' expression '{' ... '}' ;
```

#### Example
```rust
// Loops while condition is true
//
// Note: condition is evaluated *before* an iteration
while condition {
    // ...
}
```

### Do-while loop

#### Syntax
```c
do_while_statement:
'do' '{' ... '}' 'while' expression ';' ;
```

#### Example
```dart
// Loops while condition is true
//
// Note: condition is evaluated *after* an iteration,
//       so even if condition is false before this statement
//       it will still run once.
do {
    // ...
} while condition;
```


### Special loop statements

#### break

Immediately exits a loop. The `break` statement can be used in any loop structure.

##### Syntax
```c
break_statement:
'break' ';' ;
```

##### Example
```rust
var i: u16 = 0;

loop {
  if i == 5 {
    // Exit the loop once i is 5
    break;
  }

  i += 1;
}
```

#### continue

Skips the remainder of an iteration. The `continue` statement can be used in any loop structure.

##### Syntax
```c
continue_statement:
'continue' ';' ;
```

##### Example
```dart
var i: u16 = 0;

while i < 10 {
  if i % 2 == 0 {
    // Skip even numbers
    continue;
  }

  // i will only be an odd number here
}
```