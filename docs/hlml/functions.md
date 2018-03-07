# HLML Functions

## Definition
```c
function_stmt:
type IDENTIFIER '(' parameter ( ',' parameter )* ')' '{' 
    function_body 
'}'

parameter:
type IDENTIFIER
```

```c
/// Parameter-less function which returns no value
void function() {
    // ...
}
```

```c
/// Function which takes 2 16-bit integers and returns their sum
word add(word a, word b) {
    return a + b;
}
```

```c
/// Void function with a return
void function(word a) {
    if a < 5 { return; }

    // ...
}
```

## Executable Entry Points
The starting point of a program happens in a special `entry` function:

```c
entry {
    // ...
}
```

**Note:** Exactly one `entry` function must exist per executable.

## Calling Functions

```c
word add(word a, word b) {
    return a + b;
}

entry {
    word a = 5;

    // Each argument can be any expression
    word c = add(a, 6 + 2); // c == 13
}
```

## "Pass-By Value"
In HLML, **all** variables as passed by value to functions (i.e. the value is copied into the parameter). 

```dart
void func(word a) {
    // a equals 40 here
    
    a = 20;

    // a now equals 20
}

entry {
    word variable = 40;

    func(variable);

    // variable still equals 40 here!
}
```

**This includes arrays:**
```dart
void func(word[3] array) {
    // 'array' is a copy of the value passed!

    array[1] = 780;
}

entry {
    word[3] values = [1, 2, 3];

    func(values);

    // values[1] equals 2 still!
}
```

## "Pass-By Reference"
Passing a *reference* to a value requires pointers, [which is explained here](pointers.md#using-pointers-to-pass-by-reference).