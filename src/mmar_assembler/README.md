# mmar_assembler

The Macro MAR assembler.

## Usage

1. Install [the Dart SDK](https://www.dartlang.org/tools/sdk) (minimum version is 2.0.0).
2. Run `pub get` in this directory to pull down dependencies.
3. Run the assembler by doing `pub run bin/main.dart` from this directory.
    - Running `main.dart` without any arguments will display help information.

### Examples

#### Assembling a MMAR program
To assemble the MMAR file `main.mmar` into the MAR source file `main.out.mar`:

```batch
pub run bin/main.dart --input="main.mmar" --output="main.out.mar"
```

**Note:** This will also assemble any files included from `main.mmar`. Everything is assembled into the single output file.

#### Creating binary MAR code
The assembler's output type is specified with the `outtype` argument (or `t` for short). The following will assemble `main.mmar` into the MAR binary file `main.bin`:
```batch
pub run bin/main.dart --input="main.mmar" --output="main.bin" --outtype="binary"
```

## Testing
Test MMAR programs should be created under the [test](./test) directory. Each subfolder represents a test case. Output files should use the file extensions `.out.mar` for text output and `.bin` for binary (as these are already ignored by git).

Since this project is mainly for fun, MMAR tests do not have to be super comprehensive. Unit tests for the Dart code are also not currently necessary.