[[← back]](./README.md)

# HLML Enums

## Syntax
```c
enum_declaration:
'enum' IDENTIFIER '{' enum_values '}' ;

enum_values:
enum_value ( ',' enum_value )* ;

enum_value:
IDENTIFIER ( '=' expression )? ;
```

## Examples
```rust
// Enum with explicit values
enum Hardware {
  Legs = 0x0001,
  Laser = 0x0002,
  Lidar = 0x0003,
  Hologram = 0x0009,
  Battery = 0x000A
}

// Enum with implicit values
enum SomeEnum {
  A, // == 0
  B, // == 1
  C, // == 2
  D = 10, // == 10
  E, // == 11
  F // == 12
}
```

```dart
// Usage example
enum Foo {
  A,
  B,
  C
}

entry {
  var d: Foo = Foo.A;

  if d == Foo.A {
    d = Foo.C;
  }
}
```

## Type Casting enum <-> u16
All enum values are backed by a `u16` in HLML. Therefore, an enum variable can be casted to a `u16`, and vise versa:

```rust
enum Foo {
  A,
  B = 0x0200
}

entry {
  let value: u16 = 0;
  let foo: Foo = value as Foo; // foo == Foo.A

  let bar: Foo = Foo.B;
  let value2: u16 = bar as u16; // value2 == 0x0200
}
```

Casting a `u16` to an enum that does not have a named value for that number is allowed:

```rust
enum Foo {
  A = 0
}

entry {
  let value: u16 = 40;
  let value2: Foo = value as Foo; // value2 == 40, but as type Foo!
}
```