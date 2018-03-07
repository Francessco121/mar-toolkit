# HLML Variable Syntax

## Top-level
```dart
/// Mutable top-level variable
word a = 3;

/// Immutable top-level variable
final word b = 5;

/// Constant top-level variable
const word C = 10;

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
    word a = 3;
    a = 5;

    // Scoped immutable variable
    final word b = 5;
    b = 2; // Compile-time error!

    // Constant immutable variable
    const word C = 10;
    C = 20; // Compile-time error!
}
```

## Uninitialized Variables

### In Scopes
Variables **inside of a function** that are neither `const` nor `final` do not require an initializer. This means that the variable is declared and has a memory address, but its value is undefined.

```dart
entry {
    // Allocate space on the stack for 'local'
    word local;

    word a = local; // 'a' here could be anything!

    local = 30; // 'local' is now initialized

    word b = local; // b == 30
}
```

### Top-level
Top-level variables always require an initializer. Reading from a top-level variable is guaranteed to be safe (in the sense that the value is not undefined).

```dart
word a; // Compile-time error!

entry { }
```

## Modifiers

### `const`
Specifies that the variable's value is known at compile-time and is readonly after initialization. Note: `const` is *not* part of the type in HLML.

#### Examples
```dart
const word A = 40;

A = 20; // Compile-time error! Cannot change a constant at run-time.
```

```dart
int getInteger() { ... }

const word B = getInteger(); // Compile-time error! Value not known at compile-time.
```

```dart
const word C; // Compile-time error! Constants must have a value upon initialization.
```

### `final`
Specifies that the variable's value is known at declaration time and is readonly after initialization. Note: `final` is *not* part of the type.

#### Examples
```dart
final word a = 30;

a = 10; // Compile-time error! Cannot change a final after initialization.
```

```dart
int getInteger() { ... }

final word b = getInteger(); // OK!
```

```dart
final word c; // Compile-time error! Final variables must have a value upon initialization.
```