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

## Usage
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