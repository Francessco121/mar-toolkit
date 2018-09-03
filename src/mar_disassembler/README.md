# mar_disassembler

A disassembler for binary MAR code.

## Usage

The only prerequisite is [the Dart SDK](https://www.dartlang.org/tools/sdk) (version 2.0.0 or higher).

### Pub activation

This is the recommended option if you intend on just using the application, or would like to run a development copy from any directory.

1. Run `pub global activate --source path <path to this folder>`.
2. Run the disassembler by doing `mar_disassembler <args>`.
    - If this doesn't work, see [the Dart docs for pub global](https://www.dartlang.org/tools/pub/cmd/pub-global#running-a-script). You might not have the pub `bin` folder in your path.

### Without pub activation

1. Run `pub get` in this directory to pull down dependencies.
2. Run the disassembler by doing `pub run bin/mar_disassembler.dart` from this directory.

### Examples

#### Listing help information
Running the disassembler with the command `help` will display help info:

```bat
mar_disassembler help
```

#### Disassembling a binary
To disassemble the MAR binary file `program.bin` into the MAR source file `program.out.mar`:

```bat
mar_disassembler --input=program.bin --output=program.out.mar
```

Alternatively:
```bat
mar_disassembler -i program.bin -o program.out.mar
```

#### Disassembling only part of a binary
The region of the input file that is read can be changed with the `start-offset` and `end-offset` arguments. This can be useful for example, to only read the first 100 bytes of a downloaded floppy binary from MAR:

```bat
mar_disassembler -i floppy.bin -o floppy.out.mar --end-offset=100
```

## Testing
Test programs to be disassembled are placed under the [test](./test) directory. Each subfolder represents a test case. Output files should use the file extension `.out.mar` (as this extension is already ignored by git).

A source MAR or MMAR file should be included in each test case, and named `source.(m)mar`. This is so the disassembled result can be compared to the source code which produced the binary.

Since this project is mainly for fun, disassembler tests do not have to be super comprehensive. Unit tests for the Dart code are also not currently necessary.