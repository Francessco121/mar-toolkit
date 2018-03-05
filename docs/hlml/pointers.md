# HLML Pointers

## Pointers to Arbitrary Memory
```c
// Casting a word to a pointer yields a pointer to that offset in memory
//
// Note: 'const' here applies to the pointer itself, not the value being pointed to.
//       '*pointer = 10' would still work, but
//       'pointer = 0x0200' would not.
const ptr<word> pointer = 0x0100 as ptr<word>;

// To create a constant read-only pointer, mark the inner type as 'final'.
//
// Note: The type-cast does not require 'final', that will be inferred.
const ptr<final word> readonlyPointer = 0x0100 as ptr<word>;
```

## Using Pointers to "Pass-By Reference"
```c
/// Increments the given [valuePtr]'s value.
void increment(ptr<word> valuePtr) {
    *valuePtr = *valuePtr + 1;
}

entry {
    word a = 0;

    // Passing the address of 'a' lets 'increment' modify it
    increment(&a);

    // a == 1
}
```
