import 'dart:io' as io;

import 'compiling/ast_line_compiler.dart';
import 'writing/text_writer.dart';
import 'assemble_error.dart';
import 'assembler_state.dart';
import 'source.dart';
import 'utils.dart';

class AssembleResult {
  final dynamic output;
  final List<AssembleError> errors;

  AssembleResult({this.output, this.errors = const []});
}

class Assembler {
  AssembleResult assemble(String inputFilePath, String outputFilePath) {
    // Open the file
    final inputFile = new io.File(inputFilePath);
    final String inputFileContents = inputFile.readAsStringSync();
    final rootSource = Source(inputFile.uri, inputFileContents);

    // Create an assembler state
    final state = AssemblerState(rootSource);

    // Parse file and compile macros (will handle other file includes)
    final result = compileFileToLines(rootSource, state.sourceTree.root, state);

    final List<AssembleError> aggregatedErrors = result.item2;

    // Compile the AST lines
    final compiler = new AstLineCompiler();
    final AstLineCompileResult compileResult = compiler.compile(result.item1);

    aggregatedErrors.addAll(compileResult.errors);

    if (aggregatedErrors.isNotEmpty) {
      // Don't output assembly if an assemble error occurred
      return AssembleResult(errors: result.item2);
    } else {
      // Write the IR to a textual MAR form
      final writer = new TextWriter();
      final String compiledMarContents = writer.write(compileResult.lines);

      return AssembleResult(output: compiledMarContents);
    }
  }
}