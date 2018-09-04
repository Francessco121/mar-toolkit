import 'dart:async';
import 'dart:io' as io;

import 'package:args/command_runner.dart';

import '../constants.dart';

class WriteCommand extends Command {
  @override
  final String name = 'write';

  @override
  final String description = 'Write a binary file to a floppy media.';

  WriteCommand() {
    argParser.addOption('media',
      abbr: 'm',
      help: 'A file path to the floppy media.',
      valueHelp: 'FILE PATH'
    );

    argParser.addOption('binary',
      abbr: 'b',
      help: 'A file path to the binary file.',
      valueHelp: 'FILE PATH'
    );

    argParser.addOption('sector',
      abbr: 's',
      help: 'The sector to write the binary file to.',
      valueHelp: '0-${floppySectors - 1}'
    );
  }

  @override
  Future<void> run() async {
    final String mediaFilePath = argResults['media'];
    final String binaryFilePath = argResults['binary'];
    final String sectorString = argResults['sector'];

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

    if (sectorString == null || sectorString.trim().isEmpty) {
      print("Option 'sector' is required.");
      return;
    }

    final int sector = int.tryParse(sectorString);

    if (sector == null || sector < 0 || sector >= floppySectors) {
      print("Option 'sector' must be an integer between 0 and ${floppySectors - 1}.");
      return;
    }

    final mediaFile = new io.File(mediaFilePath);
    final binaryFile = new io.File(binaryFilePath);

    // Ensure files exist
    if (!mediaFile.existsSync()) {
      print("Could not find media file at '$mediaFilePath'.");
      return;
    }

    if (!binaryFile.existsSync()) {
      print("Could not find binary file at '$binaryFilePath'.");
      return;
    }

    // Open the floppy media file
    final io.RandomAccessFile media = 
      await mediaFile.open(mode: io.FileMode.writeOnlyAppend);

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

      // Get the length
      final int binaryLength = await binaryFile.length();

      // Ensure the binary will fit
      final int mediaByteOffset = sector * (512 * 2);

      if (mediaByteOffset + binaryLength > floppyMediaSizeInBytes) {
        print(
          'Binary file will not fit into the floppy media.\n'
          'Try a lower sector or use a smaller binary.\n'
          'Binary is ${(mediaByteOffset + binaryLength) - floppyMediaSizeInBytes} '
          'bytes too large if used at sector $sector ($mediaByteOffset byte offset).'
        );

        return;
      }

      // Seek to the sector
      await media.setPosition(mediaByteOffset);

      // Open the binary file
      final Stream<List<int>> binaryStream = binaryFile.openRead();

      // Copy the binary
      final StreamSubscription<List<int>> subscription = 
        binaryStream.listen(media.writeFromSync);

      try {
        await subscription.asFuture();
      } finally {
        await subscription.cancel();
      }

      print(
        "Wrote $binaryLength bytes to '$mediaFilePath' "
        'starting at sector $sector ($mediaByteOffset byte offset).'
      );
    } finally {
      await media.close();
    }
  }
}