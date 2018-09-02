# mar_disassembler

A disassembler for binary MAR code.

## Usage

1. Install [the Dart SDK](https://www.dartlang.org/tools/sdk) (minimum version is 2.0.0).
2. Run `pub get` in this directory to pull down dependencies.
3. Run the disassembler by doing `pub run bin/main.dart` from this directory.
    - Running `main.dart` without any arguments will display help information.

### Example
To disassemble the MAR binary file `program.bin` into the MAR source file `program.out.mar`:

```batch
pub run bin/main.dart --input="program.bin" --output="program.out.mar"
```

## Testing
Test programs to be disassembled are placed under the [test](./test) directory. Each subfolder represents a test case. Output files should use the file extension `.out.mar` (as this extension is already ignored by git).

A source MAR or MMAR file should be included in each test case, and named `source.(m)mar`. This is so the disassembled result can be compared to the source code which produced the binary.

Since this project is mainly for fun, disassembler tests do not have to be super comprehensive. Unit tests for the Dart code are also not currently necessary.