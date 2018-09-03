import 'dart:async';
import 'dart:io' as io;
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:args/args.dart';
import 'package:mar_disassembler/mar_disassembler.dart';

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

  _parser.addOption('startoffset',
    help: 
      'The byte offset to start reading from in the input file. '
      'If not specified, will read from the beginning of the file.',
    valueHelp: 'INTEGER'
  );

  _parser.addOption('endoffset',
    help: 
      'The byte offset to stop reading at in the input file (exclusive). '
      'If not specified, will read to the of the file.',
    valueHelp: 'INTEGER'
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
  final String startOffsetString = results['startoffset'];
  final String endOffsetString = results['endoffset'];

  final int startOffset = startOffsetString == null ? null : int.tryParse(startOffsetString);
  final int endOffset = endOffsetString == null ? null : int.tryParse(endOffsetString);

  // Validate arguments
  if (inputFilePath == null) {
    _displayUsageError("Option 'input' is required.");
    return 1;
  }

  if (outputFilePath == null) {
    _displayUsageError("Option 'output' is required.");
    return 1;
  }

  if (startOffsetString != null && startOffset == null) {
    _displayUsageError("Option 'startoffset' must be a valid integer.");
    return 1;
  }

  if (endOffsetString != null && endOffset == null) {
    _displayUsageError("Option 'endoffset' must be a valid integer.");
    return 1;
  }

  if (startOffset != null && endOffset != null && endOffset < startOffset) {
    _displayUsageError("Option 'endoffset' cannot be less than the 'startoffset' option.");
    return 1;
  }

  // Time the disassembly
  final stopwatch = Stopwatch();
  stopwatch.start();

  // Assemble the file
  final bool success = await _disassembleFile(inputFilePath, outputFilePath,
    startOffset: startOffset,
    endOffset: endOffset
  );

  // Let the user know how long it took to disassemble the program
  stopwatch.stop();
  print('Completed in ${stopwatch.elapsed}.');

  // Return the appropriate exit code
  return success ? 0 : 1;
}

Future<bool> _disassembleFile(String inputFilePath, String outputFilePath, {
  int startOffset,
  int endOffset
}) async {
  // Load the input
  final inputFile = new io.File(inputFilePath);

  if (!(inputFile.existsSync())) {
    print("Input file '$inputFilePath' does not exist.");
    return false;
  }

  // Get the length of the input file
  final int inputLength = await inputFile.length();

  // Calculate the buffer length
  int bufferLength;

  if (startOffset != null && endOffset != null) {
    bufferLength = math.min(inputLength, endOffset - startOffset);
  } else if (startOffset != null) {
    bufferLength = math.max(0, inputLength - startOffset);
  } else if (endOffset != null) {
    bufferLength = math.min(inputLength, endOffset);
  } else {
    bufferLength = inputLength;
  }

  // Read the entire file into memory as a Uint8List
  final data = new Uint8List(bufferLength);

  final Stream<List<int>> stream = inputFile.openRead();

  int position = 0;
  int filePosition = 0;

  final subscription = stream.listen((List<int> chunk) {
    for (int byte in chunk) {
      if (endOffset != null && filePosition >= endOffset) {
        return;
      }

      if (startOffset == null || filePosition >= startOffset) {
        data[position++] = byte;
      }

      filePosition++;
    }
  });

  try {
    await subscription.asFuture();
  } finally {
    await subscription.cancel();
  }

  // Disassemble the file
  final String disassembledMarSource = disassembleBinary(
    Source(inputFile.uri, startOffset ?? 0, endOffset ?? inputLength),
    data
  );

  // Output the results
  final outputFile = new io.File(outputFilePath);
  await outputFile.writeAsString(disassembledMarSource);

  return true;
}

void _displayUsageError(String message) {
  print(message);
  print('');
  _displayUsage();
}

void _displayUsage() {
  print('mar_disassembler options:');
  print(_parser.usage);
}