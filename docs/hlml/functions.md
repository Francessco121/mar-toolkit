# HLML Functions

```c
'fn' type IDENTIFIER '(' parameter ( ',' parameter )* ')' '{' 
    function_body 
'}'
```

```rust
/// Parameter-less function which returns no value
fn void function() {
    // ...
}
```

```rust
/// Function which takes 2 16-bit integers and returns their sum
fn word add(word a, word b) {
    return a + b;
}
```

```rust
/// Void function with a return
fn void function(word a) {
    if a < 5 { return; }

    /// ...
}
```