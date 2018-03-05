# HLML Types

## Built-in Types
### Integers
- `byte` - 8-bit unsigned integer
- `sbyte` - 8-bit signed integer
- `word` - 16-bit signed integer
- `uword` - 16-bit unsigned integer

### Boolean
- `bool` - Represents either `true` or `false`.

### Special
- `void` - Specifies that a function returns nothing. Only allowed to appear as a function return type.
- `ptr<T>` - Represents a pointer to the given type `T` (e.g. `ptr<word>`).


## Modifiers

### `const`
A readonly value known at compile time.

#### Examples
```c
const word A = 40;

A = 20; // Compile-time error! Cannot change a constant at run-time.
```

```c
int getInteger() { ... }

const word B = getInteger(); // Compile-time error! Value not known at compile-time.
```

```c
const word C; // Compile-time error! Constants must have a value upon initialization.
```

### `final`
Allows a variable of this type to receive a value at run-time once upon initialization. Any attempt to change a final after initialization is a compile-time error.

#### Examples
```c
final word a = 30;

a = 10; // Compile-time error! Cannot change a final after initialization.
```

```c
int getInteger() { ... }

final word b = getInteger(); // OK!
```

```c
final word c; // Compile-time error! Final variables must have a value upon initialization.
```