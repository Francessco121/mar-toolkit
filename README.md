# The MAR Toolkit

The MAR toolkit is a set of programs designed for building bots for the game [Much Assembly Required](https://github.com/simon987/Much-Assembly-Required).

> Note: This project is not officially part of the game.

## Features

### Macro MAR (MMAR) assembly language
The Macro MAR language is designed to be a superset of Much Assembly Required's language. In addition to all the features of MAR, MMAR adds its own features such as macros, file modularity, and assemble-time math.

- [Macro MAR Language Reference](./docs/mmar)
- [Macro MAR Assembler](./src/mmar_assembler)

### MAR Disassembler
The toolkit contains a disassembler that can be used to inspect binary MAR code.

- [MAR Disassembler](./src/mar_disassembler)

### MAR Floppy Manager
A 'floppy disk' manager is included in the toolkit to ease the process of reading/writing binary data to/from 'MAR floppy disks'.

- [MAR Floppy Manager](./src/mar_floppy_manager)

## Contents
- [docs](./docs) - Contains the MMAR language reference and other information.
- [src](./src) - Contains the toolkit's applications and libraries.