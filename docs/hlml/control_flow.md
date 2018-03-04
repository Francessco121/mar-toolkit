# HLML Control Flow

## Branches

### If/Else If/Else
```c
'if' expression '{' 
    then_block 
'}' ( 
    'else' ( '{' else_block '}' ) 
         | ( 'if' if_statement )
)?
```

#### Simple if
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
var word i = ...;

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
```c
'loop' '{' loop_block '}'
```

```rust
// Loops until a break statement
loop {
    // ...
}
```

### While loop
```c
'while' expression '{' while_block '}'
```

```rust
// Loops while condition is true
//
// Note: condition is evaluated *before* an iteration
while condition {
    // ...
}
```

### Do-while loop
```c
'do' '{' do_while_block '}' 'while' expression ';'
```

```rust
// Loops while condition is true
//
// Note: condition is evaluated *after* an iteration,
//       so even if condition is false before this statement
//       it will still run once.
do {
    // ...
} while condition;
```

### For loop
```c
'for' ( var_declaration | expression_stmt | ';') expression? ';' expression? '{'
    for_block
'}'
```

**Note:** Each of the 3 parts of a `for` statement are optional.

```rust
for var word i = 0; i < 10; i = i + 1 {
    // loops 10 times
}
```

```rust
var word i = 0;
for i = 3; i < 5; i = i + 1 {
    // loops 2 times
}
```

```rust
var word i = 0;
for ; i < 5; i = i + 1 {
    // loops 5 times
}
```

```rust
var word i = 0;
for ; i < 5; {
    // loops 5 times
    i = i + 1;
}
```

```rust
for ;; {
    // loops infinitely
}
```
### Special loop statements

#### break
```c
'break' ';'
```

Immediately exits a loop. The `break` statement can be used in any loop structure.

```rust
var i = 0;
loop {
    if i == 5 {
        // Exit the loop once i is 5
        break;
    }

    i++;
}
```

#### continue
```c
'continue' ';'
```

Skips the remainder of an iteration. The `continue` statement can be used in any loop structure.

```rust
var i = 0;
while i < 10 {
    if i % 2 == 0 {
        // Skip even numbers
        continue;
    }

    // i will only be an odd number here
}
```