[[← back]](./)

# Binary Assembly in MMAR

The MMAR assembler supports assembling MMAR and MAR code into binary form. [See the assembler docs](../../src/mmar_assembler) for how to actually assemble a source file into binary.

## Contents

- [ORG directive differences](./org-directive-differences)

## ORG directive differences

When assembling binary MAR, the 'origin' of the program is handled a little differently. 

If the `ORG` directive is specified, the assembler will function just like the game's assembler. Addresses will be resolved assuming that the program starts at the address specified by the `ORG` directive. 

However, when the `ORG` directive **is not specified**, the default value differs from the game's assembler and the MMAR assembler. The game's assembler will use the default address of `0x0200`, while the MMAR assembler will default to `0x0000`.