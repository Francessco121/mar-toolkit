import 'dart:async';
import 'dart:collection';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:args/args.dart';
import 'package:hlml_compiler/hlml_compiler.dart';
import 'package:mar/mar.dart';

final _parser = ArgParser();

Future<int> main(List<String> args) async {
  // Parse arguments
  _parser.addOption('input',
    abbr: 'i',
    help: 'A path to the High Level MAR Language file (.hlml) to be compiled.',
    valueHelp: 'FILE PATH'
  );

  _parser.addOption('output',
    abbr: 'o',
    help: 'A path to write the compiled result to.',
    valueHelp: 'FILE PATH'
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

  // Validate arguments
  if (inputFilePath == null) {
    _displayUsageError("Option 'input' is required.");
    return 1;
  }

  if (outputFilePath == null) {
    _displayUsageError("Option 'output' is required.");
    return 1;
  }

  // Time the compilation
  final stopwatch = Stopwatch();
  stopwatch.start();

  // Compile the program
  final bool success = await _compileFile(inputFilePath, outputFilePath);

  // Let the user know how long it took to compile their program
  stopwatch.stop();
  print('Completed in ${stopwatch.elapsed}.');

  // Return the appropriate exit code
  return success ? 0 : 1;
}

Future<bool> _compileFile(String inputFilePath, String outputFilePath) async {
  // Load the input source
  Source entrySource;
  try {
    entrySource = await Source.createFromFile(inputFilePath);
  } on io.FileSystemException catch (ex) {
    print(ex);
    return false;
  }

  // Compile the program
  final ScanResult scanResult = scan(entrySource);
  final ParseResult parseResult = parse(scanResult.tokens);
  final CompileResult compileResult = compile(parseResult.statements);

  // Aggregate problems
  final errors = <HlmlProblem>[]
    ..addAll(scanResult.problems.errors)
    ..addAll(parseResult.problems.errors)
    ..addAll(compileResult.problems.errors);

  final warnings = <HlmlProblem>[]
    ..addAll(scanResult.problems.warnings)
    ..addAll(parseResult.problems.warnings)
    ..addAll(compileResult.problems.warnings);

  // Display problems
  if (errors.isNotEmpty) {
    print('ERRORS:');

    for (final HlmlProblem problem in errors) {
      print(problem.sourceSpan.message(problem.message));
    }
  }

  if (warnings.isNotEmpty) {
    print('WARNINGS:');

    for (final HlmlProblem problem in warnings) {
      print(problem.sourceSpan.message(problem.message));
    }
  }

  // Output the file if successful
  if (errors.isEmpty) {
    final String output = assembleText(compileResult.lines);

    final outputFile = new io.File(outputFilePath);
    await outputFile.writeAsString(output);

    return true;
  } else {
    return false;
  }
}

void _displayUsageError(String message) {
  print(message);
  print('');
  _displayUsage();
}

void _displayUsage() {
  print('hlmlc options:');
  print(_parser.usage);
}