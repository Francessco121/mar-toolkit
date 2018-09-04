import 'dart:async';
import 'dart:io' as io;

import 'package:args/command_runner.dart';

import '../constants.dart';

class CreateCommand extends Command {
  @override
  final String name = 'create';

  @override
  final String description = 'Creates a blank floppy media.';

  CreateCommand() {
    argParser.addOption('output',
      abbr: 'o',
      help: 'The file path to create the media at.',
      valueHelp: 'FILE PATH',
      defaultsTo: './floppy.bin'
    );

    argParser.addFlag('force',
      abbr: 'f',
      help: 'If specified, the media will be created even if it overwrites a file.',
      negatable: false
    );
  }

  @override
  Future<void> run() async {
    final String outputFilePath = argResults['output'];
    final bool force = argResults['force'];

    // Validate arguments
    if (argResults.rest.isNotEmpty) {
      print("Unknown arguments: '${argResults.rest.join(' ')}'");
      return;
    }

    if (outputFilePath == null || outputFilePath.trim().isEmpty) {
      print("Option 'output' is required.");
      return;
    }

    final outputFile = new io.File(outputFilePath);

    // Ensure the file does not exist if force is not specified
    if (!force && outputFile.existsSync()) {
      print("A file at '$outputFilePath' already exists. Specify the --force flag to overwrite it.");
      return;
    }

    // Create the file
    final file = await outputFile.open(mode: io.FileMode.write);

    try {
      await file.truncate(floppyMediaSizeInBytes);
    } finally {
      await file.close();
    }

    print("Created floppy media at '$outputFilePath'.");
  }
}