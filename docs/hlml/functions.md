[[← back]](./README.md)

# HLML Functions

Functions in HLML work very similarly to other languages. They are a named block of code that takes optional input and optionally outputs a value in return. A key difference between HLML and other 'lower-level' languages such as C is that HLML does not require forward declarations for functions which are defined lexically after they are used.

## Contents
- [Syntax](#syntax)
- [Examples](#examples)
- [Executable Entry Points](#executable-entry-points)
- [Calling Functions](#calling-functions)
  - [Universal Function Call Syntax (UFCS)](#universal-function-call-syntax-ufcs)

## Syntax
```dart
function_statement:
'fn' IDENTIFIER '(' parameters? ')' ( '->' type )? '{' ... '}' ;

parameters:
parameter ( ',' parameter )* ;

parameter:
IDENTIFIER ':' type ;
```

## Examples
```rust
/// Parameter-less function which returns no value.
fn function() {
  // ...
}
```

```rust
/// Function which takes 2 unsigned 16-bit integers and returns their sum.
fn add(a: u16, b: u16) -> u16 {
  return a + b;
}
```

```rust
/// Function which returns no value but still uses a return
/// to stop early.
fn function(a: u16) {
  if a < 5 { return; }

  // ...
}
```

## Executable Entry Points
The starting point of a program happens in a special `entry` function. Entry functions are essentially parameterless functions with no return.

```c
entry {
  // ...
}
```

Although Much Assembly Required runs the starting point of an application every single tick, HLML emulates normal program flow by only invoking the entry function once at the start and instead resumes code where it left off when starting a new tick. See [the 'tick management' page](./tick-management.md) for more information.

**Note:** Exactly one `entry` function must exist per executable.

## Calling Functions

```rust
fn add(a: u16, b: u16) -> u16 {
  return a + b;
}

entry {
  let a: u16 = 5;

  // Each argument can be any expression
  let c: u16 = add(a, 6 + 2); // c == 13
}
```

### Universal Function Call Syntax (UFCS)

HLML supports a language feature called "universal function call syntax" or UFCS. This feature allows functions to be 'invoked on' a variable of a given type if the first parameter of that function is of the same type as the variable.

UFCS is intended to provide a simple way of 'extending' types. Normally, you cannot add methods to the type `u16`. But with UFCS, you can write functions that intend to extend `u16` without actually modifying that type in any way. The result is using a real method vs using a top-level function with UFCS looks and behaves exactly the same.

For example:
```rust
// For the given function 'add', this function can 
// be invoked in two ways...

fn add(a: u16, b: u16) -> u16 {
  return a + b;
}

entry {
  // 'add' can be called liked a normal function by
  // providing each parameter.
  let a: u16 = add(5, 6);

  // Or, with UFCS, 'add' can be invoked on an integer.
  let b: u16 = 5.add(6);

  // Both options produce the exact same underlying code.
  // UFCS is simply syntax sugar.
}
```
