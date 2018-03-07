# HLML Identifier Scoping Rules

Identifiers are scoped lexically only inside of functions in HLML.

## Top-level Scoping
HLML does not require forward declarations for top-level identifiers. The following code is valid:
```dart
entry {
    word value = func1();
}

int func1() {
    return func3() + 2;
}

int func2() {
    return 8;
}

int func3() {
    return func2() - 2;
}
```

## Scoping Inside of Functions
HLML follows lexical scoping rules inside of functions:
```dart
entry {
    word a = 10;

    {
        word b = a + 3; // OK!
    }

    word c = b; // Compile-time error! 'b' does not exist in this scope.

    word d = e; // Compile-time error! 'e' is not declared before 'd'.

    word e = 30;
}
```

Identifiers can only shadow identifiers in parent scopes:
```dart
entry {
    word a = 20;

    {
        word a = 10; // OK!

        someFunction(a); // this 'a' contains 10
    }

    someOtherFunction(a); // this 'a' contains 20

    word a = 5; // Compile-time error! Cannot re-define a variable in the same scope.
}
```