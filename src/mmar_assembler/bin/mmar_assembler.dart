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

  _parser.addOption('output-type',
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

  _parser.addOption('mode',
    abbr: 'm',
    help: 'Sets the mode of the assembler (e.g. debug or release).',
    allowed: [
      'debug',
      'release'
    ],
    allowedHelp: {
      'debug': 
        'Program will be assembled with debug information and without optimizations.',
      'release':
        'Program will be assembled without debug information and will be optimized.'
    },
    defaultsTo: 'debug'
  );

  _parser.addFlag('stack-optimizations',
    help: 
      'Specifies that stack optimizations should be applied.\n'
      'See the language docs for more information.\n'
      'Ignored if the mode is set to debug.',
    defaultsTo: false,
    negatable: false
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
    _displayUsage();
    return 0;
  }

  final String inputFilePath = results['input'];
  final String outputFilePath = results['output'];
  final String outputType = results['output-type'];
  final String mode = results['mode'];
  final bool stackOptimizations = results['stack-optimizations'];

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
  final bool success = await _assembleFile(inputFilePath, outputFilePath, 
    outputType: outputType,
    mode: mode,
    stackOptimizations: stackOptimizations
  );

  // Let the user know how long it took to assemble their program
  stopwatch.stop();
  print('Completed in ${stopwatch.elapsed}.');

  // Return the appropriate exit code
  return success ? 0 : 1;
}

Future<bool> _assembleFile(String inputFilePath, String outputFilePath, {
  String outputType,
  String mode,
  bool stackOptimizations
}) async {
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
    outputType: outputType == 'binary' ? OutputType.binary : OutputType.text,
    optimize: mode == 'release',
    stackOptimizations: stackOptimizations
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
  _displayUsage();
}

void _displayUsage() {
  print('mmar_assembler options:');
  print(_parser.usage);
}