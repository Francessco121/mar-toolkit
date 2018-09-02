import 'dart:async';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:args/args.dart';
import 'package:mar_disassembler/disassemble_binary.dart';

final _parser = ArgParser();

Future<int> main(List<String> args) async {
  // Parse arguments
  _parser.addOption('input',
    abbr: 'i',
    help: 'A path to the MAR binary file to be disassembled.',
    valueHelp: 'FILE PATH'
  );

  _parser.addOption('output',
    abbr: 'o',
    help: 'A path to write the disassembled result to.',
    valueHelp: 'FILE PATH'
  );

  ArgResults results;

  try {
    results = _parser.parse(args);
  } on FormatException catch (ex) {
    _displayUsageError(ex.message);
    return 1;
  }

  final String inputFilePath = results['input'];
  final String outputFilePath = results['output'];

  // Validate arguments
  if (inputFilePath == null) {
    _displayUsageError("Option 'input' is required.");
    return 1;
  }

  if (outputFilePath == null) {
    _displayUsageError("Option 'output' is required.");
    return 1;
  }

  // Time the disassembly
  final stopwatch = Stopwatch();
  stopwatch.start();

  // Assemble the file
  final bool success = await _disassembleFile(inputFilePath, outputFilePath);

  // Let the user know how long it took to disassemble the program
  stopwatch.stop();
  print('Completed in ${stopwatch.elapsed}.');

  // Return the appropriate exit code
  return success ? 0 : 1;
}

Future<bool> _disassembleFile(String inputFilePath, String outputFilePath) async {
  // Load the input
  final inputFile = new io.File(inputFilePath);

  if (!(inputFile.existsSync())) {
    print("Input file '$inputFilePath' does not exist.");
    return false;
  }

  // Read the entire file into memory as a Uint8List
  final int inputLength = await inputFile.length();
  final data = new Uint8List(inputLength);

  final Stream<List<int>> stream = inputFile.openRead();

  int position = 0;
  final subscription = stream.listen((List<int> chunk) {
    for (int byte in chunk) {
      data[position++] = byte;
    }
  });

  try {
    await subscription.asFuture();
  } finally {
    await subscription.cancel();
  }

  // Disassemble the file
  final String disassembledMarSource = disassembleBinary(inputFile.uri, data);

  // Output the results
  final outputFile = new io.File(outputFilePath);
  await outputFile.writeAsString(disassembledMarSource);

  return true;
}

void _displayUsageError(String message) {
  print(message);
  print('');
  print('mar_disassembler options:');
  print(_parser.usage);
}