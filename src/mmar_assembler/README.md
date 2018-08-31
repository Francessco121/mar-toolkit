# mmar_assembler

The Macro MAR assembler.

## Usage

1. Install [the Dart SDK](https://www.dartlang.org/tools/sdk) (minimum version is 2.0.0).
2. Run `pub get` in this directory to pull down dependencies.
3. Run the assembler by doing `pub run bin/main.dart` from this directory.
    - Running `main.dart` without any arguments will display help information.

### Assembling a file

As an example, to assemble the file `main.mmar` into the file `main.out.mar`:

```batch
pub run bin/main.dart --input="main.mmar" --output="main.out.mar"
```

#### Notes
- This will also assemble any files included from `main.mmar`. Everything is assembled into the single output file.
- Assembling to binary code is currently not supported, but is planned for the near future.