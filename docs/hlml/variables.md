# HLML Variable Syntax

## Top-level
```rust
// Mutable top-level variable
word a = 3;

// Immutable top-level variable
final word b = 5;

entry {
    a = 5; // Valid

    // b = 2; // Compile-time error!
}
```

## In Functions
```rust
entry {
    // Mutable variable
    word a = 3;
    a = 5;

    // Immutable variable
    final word b = 5;
    // b = 2; // Compile-time error!
}
```