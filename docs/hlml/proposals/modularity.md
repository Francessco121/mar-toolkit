[[← back]](./README.md)

# Splitting Up Code In HLML

## Importing
HLML supports importing other HLML files through the use of the `import` keyword:

**foo.hlml:**
```dart
import "bar.hlml";

fn function() {
  var number: u16 = getInteger();
}
```

**bar.hlml:**
```rust
// The 'pub' keyword exposes a top-level declaration to other files
pub fn getInteger() -> u16 {
  return 0x0123;
}
```

The `import` keyword takes a relative file path after it, so imports such as:
```dart
import "../file.hlml";
```
will work. Absolute file paths however are not allowed. 

## Exporting
HLML files can "export" other HLML files with the use of the `export` keyword. This works similarly to the `import` keyword, but instead of bringing public declarations into the file, it makes them available to any other file which imports the file containing the `export` statement.

### Example
**a.hlml**
```rust
pub let SOME_CONSTANT: u16 = 24;
````

**b.hlml**
```dart
export "a.hlml";
```

**c.hlml**
```dart
import "b.hlml";

fn function() {
  var value: u16 = SOME_CONSTANT; // value == 24
}
```

## Libraries
To support "absolute" paths, the HLML compiler can be configured with "libraries".

**hlml.yaml:**
```yaml
libraries:
  math: 'lib/math'
```

These "named file paths" can be referenced in code:
```dart
// Imports (relative to hlml.yaml) "lib/math/folder/file.hlml"
import "math:folder/file.hlml";
```