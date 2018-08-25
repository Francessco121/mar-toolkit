import 'dart:async';
import 'dart:io' as io;

import 'package:args/args.dart';
import 'package:mmar_assembler/mmar_assembler.dart';

Future<int> main(List<String> args) async {
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
  final bool success = await _assembleFile(inputFilePath, outputFilePath);

  // Return the appropriate exit code
  return success ? 0 : 1;
}

Future<bool> _assembleFile(String inputFilePath, String outputFilePath) async {
  // Open the file
  final inputFile = new io.File(inputFilePath);
  final String inputFileContents = await inputFile.readAsString();
  
  // Scan the file
  final scanner = new Scanner(inputFileContents, inputFile.uri);
  final ScanResult scanResult = scanner.scan();

  // Check for scan errors
  if (scanResult.errors.isNotEmpty) {
    for (final error in scanResult.errors) {
      print(error.sourceSpan.message(error.message));
    }

    return false;
  }

  // Parse the tokens
  final parser = new Parser(scanResult.tokens);
  final ParseResult parseResult = parser.parse();

  // Check for parse errors
  if (parseResult.errors.isNotEmpty) {
    for (final error in parseResult.errors) {
      print(error.token.sourceSpan.message(error.message));
    }

    return false;
  }

  // Compile the AST
  final compiler = new AstCompiler();
  final AstCompileResult compileResult = compiler.compile(parseResult.lines);

  // Check for compile errors
  if (compileResult.errors.isNotEmpty) {
    for (final error in compileResult.errors) {
      print(error.token.sourceSpan.message(error.message));
    }

    return false;
  }

  // Write the IR to a textual MAR form
  final writer = new TextWriter();
  final String compiledMarContents = writer.write(compileResult.lines);

  // Output the assembly
  final outputFile = new io.File(outputFilePath);
  await outputFile.writeAsString(compiledMarContents);

  return true;
}