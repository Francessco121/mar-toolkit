# HLML Functions

## Definition
```c
function_stmt:
'fn' IDENTIFIER '(' parameter ( ',' parameter )* ')' return_type '{' 
    function_body 
'}'
```

```rust
/// Parameter-less function which returns no value
fn function() void {
    // ...
}
```

```rust
/// Function which takes 2 unsigned 16-bit integers and returns their sum
fn add(a: u16, b: u16) u16 {
    return a + b;
}
```

```rust
/// Void function with a return
fn function(a: u16) void {
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

```rust
fn add(a: u16, b: u16) u16 {
    return a + b;
}

entry {
    var a = 5;

    // Each argument can be any expression
    var c = add(a, 6 + 2); // c == 13
}
```

## "Pass-By Value"
In HLML, variables as passed by value to functions (i.e. the value is copied into the parameter). 

```rust
fn func(a: u16) void {
    // a equals 40 here
    
    a = 20;

    // a now equals 20
}

entry {
    var variable = 40;

    func(variable);

    // variable still equals 40 here!
}
```

An exception to this rule is arrays and structs, neither of which are allowed to be passed by value:
```rust
// Compile-time error!
fn func(array: [3]u16) void { }
```

## "Pass-By Reference"
Passing a *reference* to a value requires pointers, [which is explained here](pointers.md#using-pointers-to-pass-by-reference).