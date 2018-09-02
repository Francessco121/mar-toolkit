import 'dart:async';
import 'dart:collection';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:args/args.dart';
import 'package:mmar/mmar.dart';

final _parser = ArgParser();

Future<int> main(List<String> args) async {
  // Parse arguments
  _parser.addOption('input',
    abbr: 'i',
    help: 'A path to the Macro MAR file (.mmar) to be assembled.',
    valueHelp: 'FILE PATH'
  );

  _parser.addOption('output',
    abbr: 'o',
    help: 'A path to write the assembled result to.',
    valueHelp: 'FILE PATH'
  );

  _parser.addOption('outtype',
    abbr: 't',
    help: 'The output type.',
    allowed: [
      'text',
      'binary'
    ],
    allowedHelp: {
      'text': 'Outputs textual MAR.',
      'binary': 'Outputs binary MAR.'
    },
    defaultsTo: 'text'
  );

  _parser.addCommand('help');

  ArgResults results;

  try {
    results = _parser.parse(args);
  } on FormatException catch (ex) {
    _displayUsageError(ex.message);
    return 1;
  }

  if (results.command?.name == 'help') {
    print('mmar_assembler options:');
    print(_parser.usage);
    return 0;
  }

  final String inputFilePath = results['input'];
  final String outputFilePath = results['output'];
  final String outputType = results['outtype'];

  // Validate arguments
  if (inputFilePath == null) {
    _displayUsageError("Option 'input' is required.");
    return 1;
  }

  if (outputFilePath == null) {
    _displayUsageError("Option 'output' is required.");
    return 1;
  }

  // Time the assembly
  final stopwatch = Stopwatch();
  stopwatch.start();

  // Assemble the file
  final bool success = await _assembleFile(inputFilePath, outputFilePath, outputType);

  // Let the user know how long it took to assemble their program
  stopwatch.stop();
  print('Completed in ${stopwatch.elapsed}.');

  // Return the appropriate exit code
  return success ? 0 : 1;
}

Future<bool> _assembleFile(String inputFilePath, String outputFilePath, String outputType) async {
  // Load the input source
  Source entrySource;
  try {
    entrySource = await Source.createFromFile(inputFilePath);
  } on io.FileSystemException catch (ex) {
    print(ex);
    return false;
  }

  /// Assemble the program
  final AssembleResult result = assembleProgram(entrySource,
    outputType: outputType == 'binary' ? OutputType.binary : OutputType.text
  );

  if (result.errors.isNotEmpty) {
    // Print errors
    for (final error in result.errors) {
      print(error.sourceSpan.message(error.message));
    }

    return false;
  } else {
    // Output the assembly
    final outputFile = new io.File(outputFilePath);
    final output = result.output;
    
    if (output is String) {
      await outputFile.writeAsString(output);
    } else {
      final UnmodifiableListView<Uint8List> binary = output;
      final sink = outputFile.openWrite();

      try {
        for (final Uint8List chunk in binary) {
          sink.add(chunk);
        }

        await sink.flush();
      } finally {
        await sink.close();
      }
    }

    return true;
  }
}

void _displayUsageError(String message) {
  print(message);
  print('');
  print('mmar_assembler options:');
  print(_parser.usage);
}