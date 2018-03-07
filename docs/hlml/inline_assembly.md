# HLML Inline Assembly

```c
'asm' '#' assembly_code '#'
```

```
entry {
    // Only allowed inside of functions
    asm #
        mov A, 4 ; Comments use ';' inside of assembly blocks
    #
}
```

## Identifier Interpolation
Variables and enum values can be 'interpolated' into inline assembly blocks. For example:

```
word a = 5;

asm #
    mov A, ${a} ; Moves 5 into register A
#
```

Enum example:
```
enum SomeEnum {
    Value1,
    Value2,
    ...
}

entry {
    asm #
        mov A, ${SomeEnum.Value1} ; Moves 0 into register A
        mov B, ${SomeEnum.Value2} ; Moves 1 into register B
    #
}
```

Interpolated identifiers can also be destination operands:
```
word a;

asm #
    mov A, 5
    mov ${a}, A ; Moves 5 into local 'a'
#
```