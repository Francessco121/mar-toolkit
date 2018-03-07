# HLML Arrays

Array types in HLML are similar to pointer types, such that any type can be made an array. Array lengths in HLML are constant and must be known at compile-time.

Allocating arrays on the stack:
```dart
// Allocates space for 3 words on the stack 
word[3] integers = [1, 2, 3];

// Allocates space for 5 words on the stack, but does not initialize them!
word[5] moreIntegers;
```

Arrays cannot be 'allocated' at an arbitrary memory location, but a pointer to any place in memory can be casted as an array:
```dart
const ptr<word> pointer = 0x0100 as ptr<word>;

// Creates a variable that treats the memory starting at 'pointer' as an array of 5 words. 
// This does not initialize that memory!
word[5] array = pointer as word[5];
```

Arrays in HLML can be indexed, starting at 0:
```dart
word[2] values = [5, 2];

word a = values[0]; // a == 5
word b = values[1]; // b == 2

// Variable indexes work too!
word index = 1;
word c = values[index]; // c == 2

// Sets the first element of 'values' to 20
values[0] = 20;
```

The 'address-of' an array in HLML is a pointer to the *entire* array:
```dart
word[3] values = [1, 2, 3];

ptr<word[3]> valuesPtr = &values;

// Sets the second element in 'values' to 4
*(array)[1] = 4;

// Note: When used as an assignment target, '*(array)[1]'
//       does not make a copy of 'array'.

// Dereferencing a pointer to an array in an expression
// will make a copy of that array:
word[3] values2 = *values;
```

To get a pointer to the beginning of the array, type-cast the array to a pointer of the array's inner type:
```dart
word[2] values = [10, 20];

// Creates a pointer to the first element in 'values'
ptr<word> valuesPtr = values as ptr<word>;

// Sets the first element in 'values' to 30
*valuesPtr = 30;
```

## Out-of-bounds Indexing
HLML does not provide any protection against indexing an array out of bounds! This is because of two reasons:

1. Array indexes may not be known at compile-time.
2. HLML has no concept of a run-time error. *

\* This may change in the future.