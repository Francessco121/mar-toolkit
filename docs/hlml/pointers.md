# HLML Pointers

## Pointers to Arbitrary Memory
```rust
// The built-in function @intToPtr can be used to convert an integer
// to a pointer to that location in memory.
//
// Note: 'const' here only applies to the variable. The value
//       pointed to can still be changed.
const pointer: &u16 = @intToPtr(0x0100);

// To specify a pointer to a value that shouldn't be changed,
// use a 'const' type:
const readonlyPointer: &const u16 = @intToPtr(0x0100);
```

## Using Pointers to "Pass-By Reference"
```rust
/// Increments the given [valuePtr]'s value.
fn increment(valuePtr: &u16) void {
    *valuePtr = *valuePtr + 1;
}

entry {
    var a = 0;

    // Passing the address of 'a' lets 'increment' modify it
    increment(&a);

    // a == 1
}
```