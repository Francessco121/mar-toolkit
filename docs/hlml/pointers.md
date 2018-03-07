# HLML Pointers

## Pointers to Arbitrary Memory
```c
// Casting a word to a pointer yields a pointer to that offset in memory
//
// Note: 'const' here only applies to the pointer. The value
//       pointed to can still be changed.
const ptr<word> pointer = 0x0100 as ptr<word>;
```

## Using Pointers to "Pass-By Reference"
```dart
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