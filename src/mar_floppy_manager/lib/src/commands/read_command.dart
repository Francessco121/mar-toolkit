import 'dart:async';
import 'dart:io' as io;

import 'package:args/command_runner.dart';

import '../constants.dart';

class ReadCommand extends Command {
  @override
  final String name = 'read';

  @override
  final String description = 'Read sectors from a floppy media into a binary file.';

  ReadCommand() {
    argParser.addOption('media',
      abbr: 'm',
      help: 'A file path to the floppy media.',
      valueHelp: 'FILE PATH'
    );

    argParser.addOption('binary',
      abbr: 'b',
      help: 'A file path to create the binary data at.',
      valueHelp: 'FILE PATH'
    );

    argParser.addOption('start-sector',
      abbr: 's',
      help: 'The sector to start reading from.',
      valueHelp: '0-${floppySectors - 1}'
    );

    argParser.addOption('end-sector',
      abbr: 'e',
      help: 
        'The sector to stop reading at (inclusive).\n'
        "If omitted, defaults to the 'start-sector'.",
      valueHelp: '0-${floppySectors - 1}'
    );

    argParser.addFlag('force',
      abbr: 'f',
      help: 'If specified, the binary file will be created even if it overwrites an existing file.',
      negatable: false
    );
  }

  @override
  Future<void> run() async {
    final String mediaFilePath = argResults['media'];
    final String binaryFilePath = argResults['binary'];
    final String startSectorString = argResults['start-sector'];
    final String endSectorString = argResults['end-sector'];
    final bool force = argResults['force'];

    // Validate arguments
    if (argResults.rest.isNotEmpty) {
      print("Unknown arguments: '${argResults.rest.join(' ')}'");
      return;
    }

    if (mediaFilePath == null || mediaFilePath.trim().isEmpty) {
      print("Option 'media' is required.");
      return;
    }

    if (binaryFilePath == null || binaryFilePath.trim().isEmpty) {
      print("Option 'binary' is required.");
      return;
    }

    if (startSectorString == null || startSectorString.trim().isEmpty) {
      print("Option 'start-sector' is required.");
      return;
    }

    final int startSector = int.tryParse(startSectorString);

    if (startSector == null || startSector < 0 || startSector >= floppySectors) {
      print("Option 'start-sector' must be an integer between 0 and ${floppySectors - 1}.");
      return;
    }

    final int endSector = endSectorString == null
      ? startSector
      : int.tryParse(endSectorString);

    if (endSector == null || endSector < 0 || endSector >= floppySectors) {
      print("Option 'end-sector' must be an integer between 0 and ${floppySectors - 1}.");
      return;
    }

    if (startSector > endSector) {
      print("Option 'start-sector' cannot be greater than option 'end-sector'.");
      return;
    }

    final mediaFile = new io.File(mediaFilePath);
    final binaryFile = new io.File(binaryFilePath);

    // Ensure the media file exists
    if (!mediaFile.existsSync()) {
      print("Could not find media file at '$mediaFilePath'.");
      return;
    }

    // Ensure the binary file does not exist or the force flag was set
    final bool binaryFileExists = binaryFile.existsSync();
    if (!force && binaryFileExists) {
      print("A file at '$binaryFilePath' already exists. Specify the --force flag to overwrite it.");
      return;
    }

    // Calculate the byte offset and length to read
    final int sectorsToRead = (endSector + 1) - startSector;
    final int mediaByteOffset = startSector * (512 * 2);
    final int mediaReadLength = sectorsToRead * (512 * 2);

    // Open the floppy media file
    final io.RandomAccessFile media = 
      await mediaFile.open(mode: io.FileMode.read);

    try {
      // Ensure media is the exact size of a floppy
      final int mediaLength = await media.length();

      if ((mediaLength != floppyMediaSizeInBytes)) {
        print(
          'Floppy media file must be exactly $floppyMediaSizeInBytes bytes '
          '(${floppyMediaSizeInBytes ~/ 1024}kb).\n'
          'Specified file is $mediaLength bytes (${mediaLength ~/ 1024}kb).'
        );

        return;
      }

      // Seek to the sector
      await media.setPosition(mediaByteOffset);

      // Open the binary file
      final io.RandomAccessFile binary = 
        await binaryFile.open(mode: io.FileMode.write);

      try {
        // Copy the sectors into the binary file
        final buffer = new List<int>(mediaReadLength);

        for (int i = 0; i < sectorsToRead; i++) {
          await media.readInto(buffer);
          await binary.writeFrom(buffer);
        }

        print(
          'Wrote sectors $startSector-$endSector ($mediaReadLength bytes) '
          "to the file '$binaryFilePath'."
        );
      } finally {
        await binary.close();
      }
    } finally {
      await media.close();
    }
  }
}