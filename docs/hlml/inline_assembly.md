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