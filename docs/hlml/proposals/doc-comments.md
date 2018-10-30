[[← back]](./README.md)

# HLML Documentation Comments

This feature is more of a standard that tooling can take advantage of to provide better intellisense for users. The compiler *could* assist tooling by including documentation comments in the AST.

Documentation comments in HLML start with three forward slashes and appear before some kind of declaration:

```csharp
/// A function that does nothing... :(
fn pointless() { }

/// Valid on variables too!
///
/// May also be multi-line!
let a: int = 4;
```
