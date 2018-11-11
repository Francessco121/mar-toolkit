[[← back]](./README.md)

# Integer Literal Extra Features in MMAR

## Contents
- [Digit Separators](#digit-separators)
- [64-bit Literals](#64-bit-literals)

## Digit Separators
Users may separate digits in integer literals with underscores ('`_`'). This can be used to increase readability of particularly long literals such as:

```asm
0b1111_0000_1010_1100
0x1234_5678
100_000_000
```

Underscores can be used anywhere in the literal (including more than one underscore next to eachother) **except** before or inside of a base prefix or at the beginning of a decimal literal. The following examples are **not** valid:

```asm
; Not valid
_0xFFFF
0_xFFFF

; Actually ends up as an identifier
_100
```

The following odd examples however **are valid**:

```asm
; Weird, but valid
0x_FFFF
0xFFFF_
0xFF_FF
0x__FF___FF____
```

## 64-bit Literals
While MAR only supports 16-bit integers, the MMAR assembler allows integer literals to be up to 64-bit. This means that `CONSTANT equ 0x1234_5678` is perfectly valid. The values are truncated to 16-bit at assemble-time, which causes them to wrap around if larger than 16-bit (e.g. `0x10001` is 'wrapped' to `0x1`). The previous example would result in `CONSTANT` equalling `0x5678` after the program has been assembled.

This is primarily a feature to improve support for [assemble-time math](./assemble-time-math.md).