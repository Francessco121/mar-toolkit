[[← back]](./README.md)

# HLML Identifier Scoping Rules

Identifiers are scoped lexically only inside of functions in HLML.

## Contents
- [Top-level Scoping](#top-level-scoping)
- [Scoping Inside of Functions](#scoping-inside-of-functions)

## Top-level Scoping
HLML does not require forward declarations for top-level identifiers. The following code is valid:
```rust
entry {
  let value: u16 = func1();
}

fn func1() u16 {
  return func3() + 2;
}

fn func2() u16 {
  return 8;
}

fn func3() u16 {
  return func2() - 2;
}
```

## Scoping Inside of Functions
HLML follows lexical scoping rules inside of functions:
```rust
entry {
  let a: u16 = 10;

  {
    let b: u16 = a + 3; // OK!
  }

  let c: u16 = b; // Compile-time error! 'b' does not exist in this scope.

  let d: u16 = e; // Compile-time error! 'e' is not declared before 'd'.

  let e: u16 = 30;
}
```

Identifiers can only shadow identifiers in parent scopes:
```rust
entry {
  let a: u16 = 20;

  {
    let a: u16 = 10; // OK!

    someFunction(a); // this 'a' contains 10
  }

  someOtherFunction(a); // this 'a' contains 20

  let a: u16 = 5; // Compile-time error! Cannot re-define a variable in the same scope.
}
```