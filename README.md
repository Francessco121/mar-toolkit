# High Level MAR Language Toolkit

The HLML toolkit is a set of programs meant for building bots for the game [Much Assembly Required](https://github.com/simon987/Much-Assembly-Required), primarily through the use of the High Level MAR Language.

**Note:** This project is very much a work in progress and anything could change.

## Current Features

### Macro MAR (MMAR) assembly language
The MMAR language is designed to be a superset of Much Assembly Required's language. In addition to all the features of MAR, MMAR adds its own features such as macros, file modularity, and assemble-time math.

- [Macro MAR language reference](./docs/mmar)
- [Macro MAR assembler](./src/mmar_assembler)

### MAR disassembler
The toolkit contains a disassembler that can be used to inspect binary MAR code.

- [MAR disassembler](./src/mar_disassembler)

## Future Goals
- The HLML compiler

## Contents
- [docs](./docs) - Contains the HLML language reference and the MMAR language reference.
- [src](./src) - Contains the toolkit's applications and libraries.