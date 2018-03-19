# HLML Identifier Scoping Rules

Identifiers are scoped lexically only inside of functions in HLML.

## Top-level Scoping
HLML does not require forward declarations for top-level identifiers. The following code is valid:
```rust
entry {
    var value = func1();
}

fn func1() u16 {
    return func3() + 2;
}

fn func2() u16 {
    return 8;
}

fn func3() u16 {
    return func2() - 2;
}
```

## Scoping Inside of Functions
HLML follows lexical scoping rules inside of functions:
```dart
entry {
    var a = 10;

    {
        var b = a + 3; // OK!
    }

    var c = b; // Compile-time error! 'b' does not exist in this scope.

    var d = e; // Compile-time error! 'e' is not declared before 'd'.

    var e = 30;
}
```

Identifiers can only shadow identifiers in parent scopes:
```dart
entry {
    var a = 20;

    {
        var a = 10; // OK!

        someFunction(a); // this 'a' contains 10
    }

    someOtherFunction(a); // this 'a' contains 20

    var a = 5; // Compile-time error! Cannot re-define a variable in the same scope.
}
```