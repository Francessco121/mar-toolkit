# HLML Structure Types

## Definition
```c
'struct' IDENTIFIER '{' 
    ( IDENTIFIER ':' TYPE ';' )+
'}'
```

User-defined complex data structures can be defined in HLML with the `struct` keyword.

```c
struct Point {
    x: u16;
    y: u16;
}
```

## Usage

### Instantiation
```c
struct Point {
    x: u16;
    y: u16;
}

entry {
    var p1 = Point {
        // Initialize fields by name
        x: 1,
        y: 4
    };

    // All field initializers are optional, this is a valid
    // default initialization:
    var p2 = Point { };

    // p2.x == 0
    // p2.y == 0
}
```

### Getting/Setting Properties
```c
struct Point {
    x: u16;
    y: u16;
}

entry {
    var p1 = Point { };

    // Retrieve field values with the '.' operator
    var x = p1.x; // x == 0

    // Set properties similarly by using the '.' operator on
    // the left side of an assignment
    p1.y = 4;
}
```

## Pointers
```c
struct Foo {
    bar: u16;
}

entry {
    var a = Foo { };
    var aPtr = &a;

    // Dereference to make a copy
    var b = *aPtr;

    // The '.' operator works the same on pointers to structs:
    aPtr.bar = 20;

    // a.bar == 20
}
```

## Example
```rust
struct Point {
    x: u16;
    y: u16;
}

fn midpoint(a: &const Point, b: &const Point) Point {
    return Point {
        x: (a.x + b.x) / 2,
        y: (a.y + b.y) / 2
    };
} 

entry {
    var p1 = Point { x: 5, y: 6 };
    var p2 = Point { x: 3, y: 12 };

    var mid = midpoint(p1, p2);

    // mid.x == 4
    // mid.y == 9

    var midX = mid.x;
    var midY = mid.y;

    // midX == 4
    // midY == 9
}
```