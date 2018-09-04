# mar_floppy_manager

A tool for working with MAR floppy media.

## Features
- Create a blank floppy media.
- Clear an existing floppy media.
- Write a binary file to any sector of the floppy.
- Read sectors from the floppy into a binary file.

See the [examples](#examples) for more info.

## Usage

The only prerequisite is [the Dart SDK](https://www.dartlang.org/tools/sdk) (version 2.0.0 or higher).

### Pub activation

This is the recommended option if you intend on just using the application, or would like to run a development copy from any directory.

1. Run `pub global activate --source path <path to this folder>`.
2. Run the tool by doing `mar_floppy_manager <args>`.
    - If this doesn't work, see [the Dart docs for pub global](https://www.dartlang.org/tools/pub/cmd/pub-global#running-a-script). You might not have the pub `bin` folder in your path.

### Without pub activation

1. Run `pub get` in this directory to pull down dependencies.
2. Run the tool by doing `pub run bin/mar_floppy_manager.dart` from this directory.

## Examples

### Contents
- [Listing help information](#listing-help-information)
- [Creating a blank media](#creating-a-blank-media)
- [Writing a binary file to a floppy](#writing-a-binary-file-to-a-floppy)
- [Reading sectors from a floppy](#reading-sectors-from-a-floppy)

### Listing help information
Running the tool with the command `help` or the flag `--help` will display help info:

```bat
mar_floppy_manager help
```

Additionally, using the flag `--help` on any command will display help information specifically for that command:

```bat
mar_floppy_manager write --help
```

### Creating a blank media
Use the `create` command to create a blank media file (the `output` argument defaults to `./floppy.bin`):

```bat
mar_floppy_manager create -o floppy.bin
```

To clear an existing media file, specify the `--force` (`-f` for short) flag to overwrite it.

```bat
mar_floppy_manager create -o floppy.bin --force
```

### Writing a binary file to a floppy
The `write` command can copy a binary a file into a floppy at any given sector. For example, to copy the file `lib.bin` into sector 4 of `floppy.bin`:

```bat
mar_floppy_manager write -m floppy.bin -b lib.bin -s 4
```

**Warning:** If the binary file is larger than 1 sector (1024 bytes), the tool will continue to write into the next sector. So writing a 2048 byte binary file into sector 4 will actually overwrite sector 4 and 5.

### Reading sectors from a floppy
The `read` command can copy any number of sectors from a floppy binary into a separate binary file. For example, to read sector 2 from `floppy.bin` into `sector_2.bin`:

```bat
mar_floppy_manager read -m floppy.bin -b sector_2.bin -s 2
```

Alternatively, a range of sectors can be read. For example, to read sectors 0 to 5 from `floppy.bin` into `sectors.bin`:

```bat
mar_floppy_manager read -m floppy.bin -b sectors.bin -s 0 -e 5
```

**Note:** The `--end-sector` (`-e`) option is inclusive and defaults to the `--start-sector` (`-s`) value.