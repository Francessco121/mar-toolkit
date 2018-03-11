# HLML Structure Types

## Definition
```c
'struct' IDENTIFIER '{' 
    ( TYPE IDENTIFIER ';' )+
'}'
```

User-defined complex data structures can be defined in HLML with the `struct` keyword.

```c
struct Point {
    word x;
    word y;
}
```

## Usage

### Instantiation
```c
struct Point {
    word x;
    word y;
}

entry {
    Point p1 = Point {
        // Initialize fields by name
        x: 1,
        y: 4
    };

    // All field initializers are optional, this is a valid
    // default initialization:
    Point p2 = Point { };

    // p2.x == 0
    // p2.y == 0
}
```

### Getting/Setting Properties
```c
struct Point {
    word x;
    word y;
}

entry {
    Point p1 = Point { };

    // Retrieve field values with the '.' operator
    word x = p1.x; // x == 0

    // Set properties similarly by using the '.' operator on
    // the left side of an assignment
    p1.y = 4;
}
```

## Pointers
Dereferencing pointers to structs can be done in two ways:
```c
struct Foo {
    word bar;
}

entry {
    Foo a = Foo { };
    ptr<Foo> aPtr = &a;

    // Normal dereference
    (*a).bar = 2;
    word aBar1 = (*a).bar; // aBar1 == 2

    // "Arrow" dereference
    a->bar = 5;
    word aBar2 = a->bar; // aBar2 == 5
}
```

## Example
```c
struct Point {
    word x;
    word y;
}

Point midpoint(Point a, Point b) {
    return Point {
        x: (a.x + b.x) / 2,
        y: (a.y + b.y) / 2
    };
} 

entry {
    Point p1 = Point { x: 5, y: 6 };
    Point p2 = Point { x: 3, y: 12 };

    Point mid = midpoint(p1, p2);

    // mid.x == 4
    // mid.y == 9

    word midX = mid.x;
    word midY = mid.y;

    // midX == 4
    // midY == 9
}
```