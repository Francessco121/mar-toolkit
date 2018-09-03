[[← back]](./)

# Stack Optimizations

This page documents all of the stack optimizations that can be applied by the MMAR assembler. [See the assembler docs](../../src/mmar_assembler) for how to to enable these.

## Contents
- [Condensed push and pop](#condensed-push-and-pop)
- [Redundant push and pop](#redundant-push-and-pop)

## Condensed push and pop
Sequential `push` and `pop` instructions can be condensed into a single `mov`:

```asm
push 0x001
pop A
```

to:

```asm
mov A, 0x001
```

## Redundant push and pop
Sequential `push` and `pop` instructions to and from the same destination can be omitted entirely:

```asm
push A
pop A
```

to:
```asm
; Nothing
```