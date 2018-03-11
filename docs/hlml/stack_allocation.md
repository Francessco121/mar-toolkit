# HLML Stack Allocation

Arbitrary amounts of memory can be allocated to the stack with the use of the `stackalloc` keyword:

```csharp
// Allocates 4 words onto the stack, and returns a pointer
// to the first one.
//
// Note: This does not initialize the memory!
ptr<word> array = stackalloc word[4];
```

## The 'stackalloc' keyword

The use of the `stackalloc` keyword is only allowed in functions. This keyword takes a type as its right operand. After the type, in brackets, is the constant number of the previous types to allocate space for. (e.g. `stackalloc word[2]` allocates 4 bytes, for 2 words). It is a compile-time error for the number to be less than or equal to zero. The keyword returns a pointer of the specified type, to the beginning of the allocated memory.
