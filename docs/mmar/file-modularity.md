[[← back]](./)

# File Modularity in MMAR

MMAR allows users to split code up into multiple files through the use of `#include`s. Each file is stitched together in the order they were included at assemble-time. The basic idea is that after all macros have been compiled, the assembler will have one big "file" containing all of a user's source code, which is then assembled into the specified output. This means that code from **any** source file can reference identifiers from any other source file, so long as they are both included into the main program at some point.

## Contents
- [\#include](#include)
- [\#once](#once)
- [Sections and includes](#sections-and-includes)

## \#include

### Definition
```asm
#include "<file path string>"
```

The `#include` macro loads the specified MMAR source file and inserts its code into the current file at the position of the `#include`. The file path may be absolute or relative to the file with the `#include`.

#### Notes
- Windows style file paths are supported when assembling on a Windows machine (though backslashes must still be escaped in the string. e.g. `"C:\\source.mmar"`).

### Example

**partial.mmar**
```asm
mov X, 0x1234
mov Y, 0x4321
```

**main.mmar**
```asm
.text
  mov A, 0x2244
  #include "partial.mmar"
  mov B, 0xFFFF
  #include "partial.mmar"
  brk
```

The above 2 files would produce the following output:
```asm
.text
  mov A, 0x2244    ; main.mmar
  mov X, 0x1234    ; partial.mmar (first include)
  mov Y, 0x4321
  mov B, 0xFFFF    ; main.mmar
  mov X, 0x1234    ; partial.mmar (second include)
  mov Y, 0x4321
  brk              ; main.mmar
```

## \#once

### Definition
```asm
#once
```

The `#once` macro is a special statement which tells the assembler that the file may only be included once. This **does not** mean that including the file twice will cause an error, instead all includes after the first will simply be ignored. Since identifiers do not need to be declared 'above' the code referencing them, this means that the `#once` macro can be used in a 'library' file that declares identifiers. The 'library' file can then be included by any other file that requires the identifiers from it, without needing to worry about the identifiers being redefined and causing an error. This is similar to using `#include` guards in C/C++ and `#pragma once` in C++.

### Example

**lib.mmar**
```asm
#once

LIB_CONSTANT equ 0x1234

some_function:
  mov A, [SP + 1]
  ret 1
```

**other.mmar**
```asm
#include "lib.mmar"

other_function:
  push LIB_CONSTANT
  call some_function
  ret
```

**main.mmar**
```asm
.text
  call other_function
  brk

#include "lib.mmar"     ; Not required, just here for example
#include "other.mmar"
```

The above 3 files would produce the following output (notice how `lib.mmar` is not duplicated despite being included twice):
```asm
.text
  call other_function
  brk

LIB_CONSTANT equ 0x1234

some_function:
  mov A, [SP + 1]
  ret 1

other_function:
  push LIB_CONSTANT
  call some_function
  ret
```

## Sections and includes

Any MMAR file can contain any number of `.text` and `.data` section lines. This allows sections to be used in a multi-file program, where any file can contribute to either section.

### The default section
By default for each file, MMAR adds code to the `.text` section. For example, the following file:

```asm
mov A, B
```

Would result in:

```asm
.text
  mov A, B
```

### How includes effect sections

The current section being contributed to is noted per-file, which means that including a file will never change the section of the file with the `#include`.

For example, the following files:

**file_1.mmar**
```asm
.data
  #include "file_2.mmar"
  DW "file_1"

.text
  ; file_1
  brk
```

**file_2.mmar**
```asm
.data
  #include "file_3.mmar"
  DW "file_2"

.text
  ; file_2
  mov A, B
```

**file_3.mmar**
```asm
; file_3
mov X, Y
```

Would result in the following MAR source:

```asm
.text
  ; file_3
  mov X, Y
  ; file_2
  mov A, B
  ; file_1
  brk

.data
  DW "file_2"
  DW "file_1"
```