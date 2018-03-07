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
```rust
enum Foo {
    A,
    B,
    C
}

entry {
    Foo d = Foo.A;

    if d == Foo.A {
        d = Foo.C;
    }
}
```

## Type Casting enum <-> word
All enum values are backed by a `word` in HLML. Therefore, an enum variable can be casted to a word, and vise versa:

```rust
enum Foo {
    A,
    B = 0x0200
}

entry {
    word value = 0;
    Foo foo = value as Foo; // foo == Foo.A

    Foo bar = Foo.B;
    word value2 = bar as word; // value2 == 0x0200
}
```

Casting a word to an enum that does not have a named value for that number is allowed:

```rust
enum Foo {
    A = 0
}

entry {
    word value = 40;
    Foo value2 = value as Foo; // value2 == 40, but as type Foo!
}
```