[[← back]](./README.md)

# Assemble-Time Math in MMAR

Although soon to also be a feature of MAR (see issue [simon987/Much-Assembly-Required#139](https://github.com/simon987/Much-Assembly-Required/issues/139)), MMAR supports performing math at assemble time of constant expressions. Valid operands of constant expression operators are integer literals and `equ` constants that have already been evaluated ([more info](#constant-references)).

### Notes
- MMAR does 64-bit math on all integers at assemble-time and then truncates the result to 16-bit when outputting assembled code (which means values will wrap around if larger than 16-bits. e.g. `0x10001` is 'wrapped' to `0x1`).
- Because of the previous note, MMAR also allows integer literals to be larger than 16-bits (e.g. `CONSTANT equ 0x12345678` is valid) ([more info](./integer-literal-extras.md#64-bit-literals)).

## Contents
- [Areas supporting assemble-time math](#areas-supporting-assemble-time-math)
- [Operators](#operators)
- [Constant references](#constant-references)

## Areas supporting assemble-time math
The following areas support constant expressions:

| Statement            | Example                       |
| :------------------- | :---------------------------- |
| Constant definitions | `CONSTANT equ 20 * 3`         |
| `ORG` directives     | `ORG 0x1000 * 2`              |
| `DW` directives      | `DW 2 * 3 DUP(10 - 2), 5 / 3` |

Notably memory and displacement operands do not currently support this.

## Operators
The following is a list of valid operators that can be used in constant expressions:

| Operation        | Symbol | Example            |
| :--------------- | :----- | :----------------- |
| Negation         | `-`    | `-(50) = -50`*     |
| Addition         | `+`    | `2 + 5 = 7`        |
| Subtraction      | `-`    | `10 - 4 = 6`       |
| Multiplication   | `*`    | `2 * 6 = 12`       |
| Integer Division | `/`    | `8 / 3 = 2`        |
| Modulo           | `%`    | `10 % 3 = 1`       |
| Grouping         | `( )`  | `10 - (5 + 2) = 3` | 

\* Parentheses are just for the example, `-50` is also valid but is not literally `-50` and instead is `50` negated at assemble-time.

## Constant references
While constant expressions support referencing `equ` defined constants, two `equ` statements may **not** reference eachother. This is because constants can only be referenced if their value has already been calculated. The following paradoxical example is not allowed by the assembler:

```asm
; Will result in an assemble error
CONSTANT_1 equ CONSTANT_2 / 2
CONSTANT_2 equ CONSTANT_1 * 2
```