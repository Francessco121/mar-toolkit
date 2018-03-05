# HLML Functions

## Definition
```c
function_stmt:
type IDENTIFIER '(' parameter ( ',' parameter )* ')' '{' 
    function_body 
'}'

parameter:
type IDENTIFIER
```

```c
/// Parameter-less function which returns no value
void function() {
    // ...
}
```

```c
/// Function which takes 2 16-bit integers and returns their sum
word add(word a, word b) {
    return a + b;
}
```

```c
/// Void function with a return
void function(word a) {
    if a < 5 { return; }

    // ...
}
```

## Executable Entry Points
The starting point of a program happens in a special `entry` function:

```c
entry {
    // ...
}
```

**Note:** Exactly one `entry` function must exist per executable.

## Calling Functions

```c
word add(word a, word b) {
    return a + b;
}

entry {
    word a = 5;

    // Each argument can be any expression
    word c = add(a, 6 + 2); // c == 13
}
```