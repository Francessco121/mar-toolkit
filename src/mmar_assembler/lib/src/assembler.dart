import 'dart:collection';
import 'dart:io' as io;
import 'dart:typed_data';

import 'compiling/ast_line_compiler.dart';
import 'compiling/identifier_extractor.dart';
import 'parsing/ast/ast.dart' as ast;
import 'writing/binary_writer.dart';
import 'writing/text_writer.dart';
import 'assemble_error.dart';
import 'assembler_state.dart';
import 'output_type.dart';
import 'source.dart';
import 'utils.dart';

class AssembleResult {
  /// Will be of type [String] if the output type was text.
  /// Will be of type [UnmodifiableListView<Uint8List>] if the output type was binary.
  final dynamic output;
  final List<AssembleError> errors;

  AssembleResult({this.output, this.errors = const []});
}

class Assembler {
  AssembleResult assemble(String inputFilePath, String outputFilePath, {
    OutputType outputType = OutputType.text
  }) {
    assert(inputFilePath != null);
    assert(outputFilePath != null);
    assert(outputType != null);

    // Open the file
    final inputFile = new io.File(inputFilePath);
    final String inputFileContents = inputFile.readAsStringSync();
    final rootSource = Source(inputFile.uri, inputFileContents);

    // Create an assembler state
    final state = AssemblerState(rootSource);

    // Parse file and compile macros (will handle other file includes)
    final resultTuple = compileFileToLines(rootSource, state.sourceTree.root, state);

    final List<ast.Line> lines = resultTuple.item1;
    final List<AssembleError> aggregatedErrors = resultTuple.item2;

    // Extract identifiers
    final IdentifierExtractionResult extractResult = extractIdentifiers(lines);
    aggregatedErrors.addAll(extractResult.errors);

    // Compile the AST lines
    final AstLineCompileResult compileResult = compileAstLines(lines, extractResult.identifiers);
    aggregatedErrors.addAll(compileResult.errors);

    if (aggregatedErrors.isNotEmpty) {
      // Don't output assembly if an assemble error occurred
      return AssembleResult(errors: aggregatedErrors);
    } else {
      if (outputType == OutputType.text) {
        // Write the IR to a textual MAR form
        final writer = new TextWriter();
        final String compiledMarContents = writer.write(compileResult.lines);

        return AssembleResult(output: compiledMarContents);
      } else if (outputType == OutputType.binary) {
        // Write the IR to binary MAR form
        final UnmodifiableListView<Uint8List> binary = writeBinary(compileResult.lines);

        return AssembleResult(output: binary);
      } else {
        throw new ArgumentError.value(outputType, 'outputType');
      }
    }
  }
}