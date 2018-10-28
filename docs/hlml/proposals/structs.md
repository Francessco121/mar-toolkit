[[← back]](./README.md)

# HLML Structure Types

> Note: This document needs a lot of work still.

## Definition
```c
struct_declaration:
'struct' IDENTIFIER ( ':' IDENTIFIER ) '{' struct_field+ '}'

struct_field:
IDENTIFIER ':' TYPE ';'

struct_method:

```

User-defined data structures can be defined in HLML with the `struct` keyword.

```csharp
struct Point {
  public let x: u16;
  public let y: u16;

  public this(x => this.x, y => this.y);

  // Or:
  public this(x: u16, y: u16) {
    this.x = x;
    this.y = y;
  }

  // Or even:
  public this(x => this.x, y: u16) {
    this.y = y;
  }

  public fn add(other: Point) Point {
    return new Point(
      x: x + other.x,
      y: y + other.y
    );

    // OR:
    return new Point(x + other.x, y + other.y);
  }
}
```

## Usage

### Instantiation
```csharp
struct Point {
  public let x: u16;
  public let y: u16;

  // Default constructor.
  public this();

  // Constructor that allows users to pass their own
  // values for x and y.
  public this(x => this.x, y => this.y);
}

entry {
  let p1: Point = new Point(
    // Initialize fields by name is optional,
    // works like a function call.
    x: 1,
    y: 4
  );

  // Using the default constructor.
  let p2: Point = new Point();

  // p2.x == 0
  // p2.y == 0
}
```

### Getting/Setting Properties
```csharp
struct Point {
  public var x: u16;
  public var y: u16;

  public this();
}

entry {
  let p1: Point = new Point();

  // Retrieve field values with the '.' operator
  let x: u16 = p1.x; // x == 0

  // Set properties similarly by using the '.' operator on
  // the left side of an assignment. The property must be
  // marked as mutable.
  p1.y = 4;
}
```

## Pointers
```csharp
struct Foo {
  public var bar: u16;

  public this();
}

entry {
    var a: Foo = new Foo();
    var aPtr: Foo* = &a;

    // Dereference to make a copy
    var b: Foo = *aPtr;

    // The '.' operator works the same on pointers to structs:
    aPtr.bar = 20;

    // a.bar == 20
}
```

## Another Example
```csharp
struct Point {
  public let x: u16;
  public let y: u16;

  public this(x => this.x, y => this.y);
}

fn midpoint(a: &const Point, b: &const Point) Point {
  return new Point(
    x: (a.x + b.x) / 2,
    y: (a.y + b.y) / 2
  );
} 

entry {
  var p1: Point = new Point(5, 6);
  var p2: Point = n ew Point(3, 12);

  var mid: Point = midpoint(p1, p2);

  // mid.x == 4
  // mid.y == 9

  var midX: u16 = mid.x;
  var midY: u16 = mid.y;

  // midX == 4
  // midY == 9
}
```