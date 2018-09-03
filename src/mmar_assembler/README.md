# mmar_assembler

The Macro MAR assembler.

## Usage

The only prerequisite is [the Dart SDK](https://www.dartlang.org/tools/sdk) (version 2.0.0 or higher).

### Pub activation

This is the recommended option if you intend on just using the application, or would like to run a development copy from any directory.

1. Run `pub global activate --source path <path to this folder>`.
2. Run the assembler by doing `mmar_assembler <args>`.
    - If this doesn't work, see [the Dart docs for pub global](https://www.dartlang.org/tools/pub/cmd/pub-global#running-a-script). You might not have the pub `bin` folder in your path.

### Without pub activation

1. Run `pub get` in this directory to pull down dependencies.
2. Run the assembler by doing `pub run bin/mmar_assembler.dart` from this directory.

### Examples

#### Listing help information
Running the assembler with the command `help` will display help info:

```bat
mmar_assembler help
```

#### Assembling a MMAR program
To assemble the MMAR file `main.mmar` into the MAR source file `main.out.mar`:

```bat
mmar_assembler --input=main.mmar --output=main.out.mar
```

Alternatively:
```bat
mmar_assembler -i main.mmar -o main.out.mar
```

**Note:** This will also assemble any files included from `main.mmar`. Everything is assembled into the single output file.

#### Creating binary MAR code
The assembler's output type is specified with the `output-type` argument (or `t` for short). The following will assemble `main.mmar` into the MAR binary file `main.bin`:
```bat
mmar_assembler --input=main.mmar --output=main.bin --output-type=binary
```

## Testing
Test MMAR programs should be created under the [test](./test) directory. Each subfolder represents a test case. Output files should use the file extensions `.out.mar` for text output and `.bin` for binary (as these are already ignored by git).

Since this project is mainly for fun, MMAR tests do not have to be super comprehensive. Unit tests for the Dart code are also not currently necessary.