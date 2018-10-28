[[← back]](./README.md)

# HLML Variables

## Contents
- [Syntax](#syntax)
- [Declaration](#declaration)
  - [Mutable variables](#mutable-variables)
  - [Immutable variables](#immutable-variables)
- [Undefined Variables](#undefined-variables)

## Syntax
```c
variable_declaration:
( 'var' | 'let' ) IDENTIFIER ':' type '=' expression ;
```

## Declaration

Variables in HLML can be declared in two ways: as a mutable variable or as an immutable variable. Variables can be declared at the top-level of a file or in any scope.

### Mutable variables

Mutable variables can be declared with the `var` keyword. Variables declared as mutable may be changed at any time in the program by other code.

```dart
// Declares a top-level mutable variable named 'a' with 
// the initial value of 3.
var a: u16 = 3;

entry {
  // Changes 'a' to be equal to 4.
  a = 4;

  // Declares a scoped mutable variabled named 'b' with
  // the initial value of 5.
  var b: u16 = 5;

  // Changes 'b' to have the value of 'a' (which is 4).
  b = a;
}
```

### Immutable variables

Immutable variables can be declared with the `let` keyword. Variables declared as immutable cannot be changed after they are declared.

> Note: While immutable variables must have a value at declaration time, that value does not necessarily have to be known at compile-time.

```rust
// Declares a top-level immutable variable (i.e. a constant)
// named 'a' with the value of 20.
let a: u16 = 20;

entry {
  // Immutable variables may not be changed, so this would
  // result in a compile-time error.
  a = 10;

  // Declares a scoped immutable variable named 'b' with
  // the value of 50. This is also a 'constant' technically
  // because the value is known at compile-time.
  let b: u16 = 50;

  // Still results in a compile-time error.
  b = 20;

  // Declares a scoped immutable variable named 'c' with
  // the value of whatever is returned from the function
  // 'getValue'. In this case, 'c' is not a 'constant',
  // but still may not be changed after declaration.
  let c: u16 = getValue();

  // Still results in a compile-time error.
  c = 0;
}
```

## Undefined Variables

All variables in HLML are required to be initialized. To explicitly state that a variable should not be initialized to *a value*, assign it to `undefined`. Only mutable variables may be initialized to undefined.

> Note: This feature is intended to be used rarely as a micro-optimization. It's much safer to give variables an initial value, even if that initial value isn't used.

```swift
entry {
  // Allocate space on the stack for 'local'
  var local: u16 = undefined;

  var a: u16 = local; // 'a' here could be anything!

  local = 30; // 'local' is now initialized to a value

  var b: u16 = local; // b == 30

  // Results in a compile-time error as immutable variables
  // *must* have a value at declaration time.
  let c: u16 = undefined;
}
```
