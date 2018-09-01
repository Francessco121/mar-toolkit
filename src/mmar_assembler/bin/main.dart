import 'dart:async';
import 'dart:collection';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:args/args.dart';
import 'package:mmar_assembler/mmar_assembler.dart';

Future<int> main(List<String> args) async {
  // Parse arguments
  final parser = ArgParser();

  void displayUsageError(String message) {
    print(message);
    print('');
    print('mmar_assembler options:');
    print(parser.usage);
  }

  parser.addOption('input',
    abbr: 'i',
    help: 'A path to the Macro MAR file (.mmar) to be assembled.',
    valueHelp: 'FILE PATH'
  );

  parser.addOption('output',
    abbr: 'o',
    help: 'A path to write the assembled result to.',
    valueHelp: 'FILE PATH'
  );

  parser.addOption('outtype',
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

  ArgResults results;

  try {
    results = parser.parse(args);
  } on FormatException catch (ex) {
    displayUsageError(ex.message);
    return 1;
  }

  final String inputFilePath = results['input'];
  final String outputFilePath = results['output'];
  final String outputType = results['outtype'];

  // Validate arguments
  if (inputFilePath == null) {
    displayUsageError("Option 'input' is required.");
    return 1;
  }

  if (outputFilePath == null) {
    displayUsageError("Option 'output' is required.");
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
  // Assemble the file
  final assembler = new Assembler();
  final AssembleResult result = assembler.assemble(inputFilePath, outputFilePath,
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
