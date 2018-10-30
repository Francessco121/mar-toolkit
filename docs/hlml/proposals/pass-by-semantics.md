[[← back]](./README.md)

# HLML Pass-By Semantics

## "Pass-By Value"
In HLML, variables as passed by value to functions (i.e. the value is copied into the parameter). 

```rust
fn func(a: u16) {
  // a equals 40 here
  
  a = 20;

  // a now equals 20
}

entry {
  var variable: u16 = 40;

  func(variable);

  // variable still equals 40 here!
}
```

An exception to this rule is arrays and structs, neither of which are allowed to be passed by value:
```rust
// Compile-time error!
fn func(array: u16[3]) { }
```

## "Pass-By Reference"
Passing a *reference* to a value requires pointers, [which is explained here](pointers.md#using-pointers-to-pass-by-reference).