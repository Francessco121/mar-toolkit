# HLML Operators

## Arithmetic
```rust
// Addition
1 + 1 // == 2

// Subtraction
2 - 3 // == -1

// Multiplication
3 * 4 // == 12

// Integer Division
10 / 2 // == 5
7 / 3 // == 2 (remainder is truncated)

// Modulus (Remainder of division)
8 % 2 // == 0
4 % 3 // == 1

// Negation
-5 // == -5
-(-10) // == 10
```

## Bitwise
```rust
// Bitwise AND
0x0001 & 0x0011 // == 0x0001

// Bitwise OR
0x1000 | 0x0010 // == 0x1010

// Bitwise XOR
0x0100 ^ 0x0110 // == 0x0010

// Bitwse NOT
~0x0011 // == 0xFFEE

// Left bit shift
0x0001 << 1 // == 0x0002

// Right bit shift
0x0100 >> 2 // == 0x0040
```

## Comparison
```rust
// Equal
1 == 1 // == true

// Not-Equal
1 != 2 // == true

// Greater-than
1 > 3 // == false

// Greater-than or equal
1 >= 4 // == false

// Less-than
5 < 10 // == true

// Less-than or equal
6 <= 12 // == true
```

## Logical
```rust
// Logical AND
true && false // == false

// Logical OR
false || true // == true

// Logical NOT
!true // == false
```

## Grouping
```rust
// Parentheses change operator precedence
2 * (3 + 2) // == 10
```

## Pointers
```rust
// Address-of
&variable

// Pointer de-reference
*pointerVariable
```

## Special
```rust
// Dot access
structure.field
```

## Shorthand
Most operators in HLML have short-hand versions for assignment.

```rust
// a = a + 3
a += 3

// a = a - 2
a -= 2

// a = a * 5
a *= 5

// a = a / 3
a /= 3

// a = a % 10
a %= 10

// a = a & 0x0010
a &= 0x0010

// a = a | 0x1000
a |= 0x1000

// a = a ^ 0x1010
a ^= 0x1010

// a = a << 3
a <<= 3

// a = a >> 2
a >>= 2
```