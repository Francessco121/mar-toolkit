# High Level MAR Language Toolkit

The HLML toolkit is a set of programs meant for building bots for the game [Much Assembly Required](https://github.com/simon987/Much-Assembly-Required), primarily through the use of the High Level MAR Language.

**Note:** This project is very much a work in progress and anything could change.

## Current Features

### Macro MAR (MMAR) assembly language
The MMAR language is designed to be a superset of Much Assembly Required's language. In addition to all the features of MAR, MMAR adds its own features such as macros, file modularity, and assemble-time math.

- [MMAR language reference](./docs/mmar)
- [MMAR assembler](./src/mmar_assembler)

## Future Goals
- The HLML compiler
- A MAR bytecode disassembler

## Contents
- [docs](./docs) - Contains the HLML language reference and the MMAR language reference.
- [src](./src) - Currently, contains the source code of the MMAR assembler.