# HLML Strings

String literals are special types in HLML. They are immutable constants which cannot be modified at runtime. String literals can be stored in variables of the type `str`.

```rust
str string = "Hello World!";
```

Strings can be read from at run-time with the use of the 'index' operator:
```rust
str string = "Hello World!";

// Indexes start at 0
word firstLetter = string[0]; // firstLetter == 'H'
```

Attempting to modify or find the address of a string is a compile-time error:
```rust
str foo = "bar";

foo[2] = 'z'; // Compile-time error! Cannot modify a constant.

ptr<str> fooPtr = &foo; // Compile-time error! Cannot get the address of a constant.
```

Marking a `str` variable as `const` is also a compile-time error, since `str` implies this already:

```rust
const str a = "hi"; // Compile-time error! 
```

## Creating Dynamic Strings

Since string literals are constants, a dynamic string in HLML is simply an "array" of words.

```rust
str helloWorld = "Hello World!";

// Use the special keyword 'strlen' to get the length of a string
// literal. This 'function' is ran at compile-time.
const word helloWorldLength = strlen(helloWorld);

// Allocate room for the string on the stack
ptr<word> helloWorldMutable = stackalloc word[helloWorldLength];

// Copy the constant
for (word i = 0; i < helloWorldLength; i = i + 1) {
    (*(helloWorldMutable + i)) = helloWorld[i];
}

// helloWorldMutable now points to the beginning of a string
// containing "Hello World!" on the stack.
```