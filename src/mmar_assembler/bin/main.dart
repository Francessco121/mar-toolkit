import 'dart:io' as io;

import 'package:args/args.dart';
import 'package:mmar_assembler/mmar_assembler.dart';

int main(List<String> args) {
  // Parse arguments
  final parser = ArgParser();

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

  final ArgResults results = parser.parse(args);

  final String inputFilePath = results['input'];
  final String outputFilePath = results['output'];

  // Validate arguments
  if (inputFilePath == null || outputFilePath == null) {
    print('mmar_assembler options:');
    print(parser.usage);
    return 1;
  }

  // Assemble the file
  final bool success = _assembleFile(inputFilePath, outputFilePath);

  // Return the appropriate exit code
  return success ? 0 : 1;
}

bool _assembleFile(String inputFilePath, String outputFilePath) {
  // Assemble the file
  final assembler = new Assembler();
  final AssembleResult result = assembler.assemble(inputFilePath, outputFilePath);

  if (result.errors.isNotEmpty) {
    // Print errors
    for (final error in result.errors) {
      print(error.sourceSpan.message(error.message));
    }

    return false;
  } else {
    // Output the assembly
    final outputFile = new io.File(outputFilePath);
    outputFile.writeAsStringSync(result.output as String);

    return true;
  }
}