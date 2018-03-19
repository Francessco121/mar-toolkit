# HLML Enums

## Definition
```c
'enum' IDENTIFIER '{'
    IDENTIFIER ( '=' expression )? 
    ( ',' IDENTIFIER ( '=' expression )? )*
'}'
```

```rust
enum Hardware {
    Legs = 0x0001,
    Laser = 0x0002,
    Lidar = 0x0003,
    Hologram = 0x0009,
    Battery = 0x000A
}

enum SomeEnum {
    A, // == 0
    B, // == 1
    C, // == 2
    D = 10, // == 10
    E, // == 11
    F // == 12
}
```

## Example Usage
```dart
enum Foo {
    A,
    B,
    C
}

entry {
    var d = Foo.A;

    if d == Foo.A {
        d = Foo.C;
    }
}
```

## Type Casting enum <-> u16
All enum values are backed by a `u16` in HLML. Therefore, an enum variable can be casted to a `u16`, and vise versa:

```dart
enum Foo {
    A,
    B = 0x0200
}

entry {
    var value = 0;
    var foo = value as Foo; // foo == Foo.A

    var bar = Foo.B;
    var value2 = bar as u16; // value2 == 0x0200
}
```

Casting a `u16` to an enum that does not have a named value for that number is allowed:

```dart
enum Foo {
    A = 0
}

entry {
    var value = 40;
    var value2 = value as Foo; // value2 == 40, but as type Foo!
}
```