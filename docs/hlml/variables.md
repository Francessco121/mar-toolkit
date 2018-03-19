# HLML Variable Syntax

## Top-level
```dart
/// Mutable top-level variable
var a = 3;

/// Immutable top-level variable
final b = 5;

/// Constant top-level variable
const C = 10;

entry {
    a = 5; // Valid

    b = 2; // Compile-time error!

    C = 15; // Compile-time error!
}
```

## In Scopes
```dart
entry {
    // Scoped mutable variable
    var a = 3;
    a = 5;

    // Scoped immutable variable
    final b = 5;
    b = 2; // Compile-time error!

    // Constant immutable variable
    const C = 10;
    C = 20; // Compile-time error!
}
```

## Type Annotations
In most cases, type annotations are optional in HLML.

```dart
// Creates a variable named 'a' of type 'u8'
var a: u8 = 30;

// Note: Variable types inferred from integer literals
//       default to 'u16'.
//
// Creates a variable named 'b' of type 'u16'
var b = 30;
```

## Undefined Variables

All variables in HLML are required to be initialized. To explicitly state that a variable should not be initialized to *a value*, assign it to `undefined`.

```dart
entry {
    // Allocate space on the stack for 'local'
    //
    // Note: The type annotation is required for variables
    //       initialized to 'undefined'
    var local: u16 = undefined;

    var a = local; // 'a' here could be anything!

    local = 30; // 'local' is now initialized to a value

    var b = local; // b == 30
}
```

## Modifiers

### `const`
Specifies that the variable's value is known at compile-time and is readonly after initialization. Note: `const` is *not* part of the type in HLML.

#### Examples
```dart
const A = 40;

A = 20; // Compile-time error! Cannot change a constant.
```

```dart
fn getInteger() u16 { ... }

const B = getInteger(); // Compile-time error! Value not known at compile-time.
```

```dart
const C: u16 = undefined; // Compile-time error! Constants must have a value upon initialization.
```

### `final`
Specifies that the variable's value is known at declaration time and is readonly after initialization. Note: `final` is *not* part of the type.

#### Examples
```dart
final a = 30;

a = 10; // Compile-time error! Cannot change a final after initialization.
```

```dart
fn getInteger() u16 { ... }

final b = getInteger(); // OK!
```

```dart
final c: u16 = undefined; // Compile-time error! Final variables must have a value upon initialization.
```