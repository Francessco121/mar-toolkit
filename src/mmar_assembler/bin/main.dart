import 'dart:async';
import 'dart:io' as io;

import 'package:args/args.dart';
import 'package:mmar_assembler/mmar_assembler.dart';

Future<int> main(List<String> args) async {
  // Parse arguments
  final parser = ArgParser();

  parser.addOption('input',
    abbr: 'i',
    help: 'A path to the Macro MAR file (.mmar) to be compiled.',
    valueHelp: 'FILE PATH'
  );

  final ArgResults results = parser.parse(args);

  final String inputFilePath = results['input'];

  // Validate arguments
  if (inputFilePath == null) {
    print('mmar_assembler options:');
    print(parser.usage);
    return 1;
  }

  // Assemble the file
  final bool success = await _assembleFile(inputFilePath);

  // Return the appropriate exit code
  return success ? 0 : 1;
}

Future<bool> _assembleFile(String filePath) async {
  // Open the file
  final file = new io.File(filePath);
  final String contents = await file.readAsString();
  
  // Scan the file
  final scanner = new Scanner(contents, file.uri);
  final ScanResult scanResult = scanner.scan();

  // Check for scan errors
  if (scanResult.errors.isNotEmpty) {
    for (final error in scanResult.errors) {
      print(error.sourceSpan.message(error.message));
    }

    return false;
  }

  // Parse the file
  final parser = new Parser(scanResult.tokens);
  final ParseResult parseResult = parser.parse();

  // Check for parse errors
  if (parseResult.errors.isNotEmpty) {
    for (final error in parseResult.errors) {
      print(error.token.sourceSpan.message(error.message));
    }

    return false;
  }

  return true;
}