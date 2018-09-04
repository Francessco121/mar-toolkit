[[← back]](./)

# Binary Assembly in MMAR

The MMAR assembler supports assembling MMAR and MAR code into binary form. [See the assembler docs](../../src/mmar_assembler) for how to actually assemble a source file into binary.

## Contents

- [Relocation sections](#relocation-sections)
- [ORG directive differences](#org-directive-differences)

## Relocation sections

The assembler can optionally prepend a 'relocation section' to an assembled binary. This is used to allow binary code to be loaded anywhere in memory, without breaking absolute memory addresses. When a relocation section is generated, the `ORG` directive is ignored and all addresses are resolved as if the program starts at address `0x0000`. This effectively makes each memory reference an offset from the beginning of the program. The relocation section contains a list of offsets from the beginning of the program that point to every memory reference in the program. This can be used to patch all each memory address before actually running the binary. 

For example, to load a binary at the address of `0x1000`, the program would read the relocation section and add `0x1000` to every memory reference in the program. After that, the program can be ran successfully.

### Relocation section format

The relocation section uses the following format:

1. Header (first 3 words)
2. Number of relocation entries (4th word)
3. Each entry (single word values)

#### Header

The relocation header is a series of 3 words that allow programs to verify whether a binary has a relocation header.

| Value    | Text |
| :------: | :--: |
| `0x0052` | R    |
| `0x004c` | L    |
| `0x0043` | C    |

#### Relocation entries

Immediately following the header is a single word containing the number of relocation entries. Each relocation entry is a single word following the number of entries. Relocation entries represent the offset from the beginning of the program to the memory address that needs to be updated. 

This means that the address of any given value that needs to be relocated can be found by:

```
address = binary_address + 4 + relocation_entry
```

Where the `binary_address` is the absolute memory address of the binary in memory, `4` is the sum of the relocation header size and the entry count value size, and `relocation_entry` is the value of a relocation entry.

The relocated address can be found by:

```
new_address = binary_address + 4 + old_address
```

Where the `old_address` is the value found at the memory location specified by the previous formula (the other two values keep the same meaning from the previous).

### Example relocation section

The following is an annotated disassembly of a program with a relocation section:

```asm
; Address   Assembly                         Binary               Text
; ----------------------------------------------------------------------
            ; Relocation header
_0x0000:    DW 0x0052                        ; 00 52              .R
_0x0001:    DW 0x004c                        ; 00 4c              .L
_0x0002:    DW 0x0043                        ; 00 43              .C

            ; Number of relocation entries
_0x0003:    DW 0x0002                        ; 00 02              ..

            ; Relocation entries
_0x0004:    DW 0x0001                        ; 00 01              ..
_0x0005:    DW 0x0006                        ; 00 06              ..

            ; Start of program
_0x0006:    call 0x0003                      ; f8 15 00 03        ø...
_0x0008:    brk                              ; 00 00              ..

            ; Where 'call 0x0003' will 
            ; point to after relocation
_0x0009:    mov A, 0x0002                    ; f8 41 00 02        øA..
_0x000b:    mov X, 0x000a                    ; f9 41 00 0a        ùA..
_0x000d:    hwi 0x0009                       ; f8 09 00 09        ø...
_0x000f:    ret                              ; 00 16              ..

            ; Where 'mov X, 0x000a' will
            ; point to after relocation
_0x0010:    DW 0x0048                        ; 00 48              .H
_0x0011:    DW 0x0065                        ; 00 65              .e
_0x0012:    DW 0x006c                        ; 00 6c              .l
_0x0013:    DW 0x006c                        ; 00 6c              .l
_0x0014:    DW 0x006f                        ; 00 6f              .o
_0x0015:    DW 0x0021                        ; 00 21              .!
_0x0016:    DW 0x0000                        ; 00 00              ..
```

The following diff shows the changes that would be made from successfully relocating the previous program:

```diff
 ...
             ; Start of program
-_0x0006:    call 0x0003                      ; f8 15 00 03        ø...
+_0x0006:    call 0x0009                      ; f8 15 00 09        ø...
 _0x0008:    brk                              ; 00 00              ..

 ...

 _0x0009:    mov A, 0x0002                    ; f8 41 00 02        øA..
-_0x000b:    mov X, 0x000a                    ; f9 41 00 0a        ùA..
+_0x000b:    mov X, 0x0010                    ; f9 41 00 10        ùA..
 _0x000d:    hwi 0x0009                       ; f8 09 00 09        ø...

 ...
```

## ORG directive differences

> Note: The `ORG` directive is ignored if the binary is assembled with a relocation section.

When assembling binary MAR, the 'origin' of the program is handled a little differently. 

If the `ORG` directive is specified, the assembler will function just like the game's assembler. Addresses will be resolved assuming that the program starts at the address specified by the `ORG` directive. 

However, when the `ORG` directive **is not specified**, the default value differs from the game's assembler and the MMAR assembler. The game's assembler will use the default address of `0x0200`, while the MMAR assembler will default to `0x0000`.