import 'dart:io' as io
;
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

import '../parsing/ast/ast.dart' as ast;
import '../scanning/token.dart';
import '../assemble_error.dart';
import '../utils.dart';

class MacroCompileResult {
  final List<ast.Line> lines;
  final List<AssembleError> errors;

  MacroCompileResult({
    @required this.lines,
    @required this.errors
  })
    : assert(lines != null),
      assert(errors != null);
}

/// Compiles all macro AST statements into a flat list of AST lines.
class MacroCompiler {
  MacroCompileResult compile(List<ast.Statement> statements, Uri sourceUri) {
    final visitor = new _MacroVisitor(sourceUri);

    for (var statement in statements) {
      if (statement is ast.Macro) {
        statement.accept(visitor);
      } else {
        // Note: Intentionally let this fail if a new [ast.Statement]
        //       implementation is made but not added here.
        //
        //       Shouldn't be a compile error because that's a bug.
        visitor.visitLine(statement as ast.Line);
      }
    }

    return MacroCompileResult(
      lines: visitor.lines,
      errors: visitor.errors
    );
  }
}

class _MacroVisitor implements ast.MacroVisitor {
  final List<ast.Line> lines = [];
  final List<AssembleError> errors = [];

  /// The directory of the source file.
  final String _sourceDirectory;

  _MacroVisitor(Uri sourceUri)
    : assert(sourceUri != null),
      _sourceDirectory = path.dirname(path.fromUri(sourceUri));

  void visitLine(ast.Line line) {
    lines.add(line);
  }

  @override
  void visitIncludeMacro(ast.IncludeMacro includeMacro) {
    final String relativefilePath = includeMacro.filePathToken.literal;

    final String absolutePath = path.normalize(path.join(_sourceDirectory, relativefilePath));
    
    // Open the file
    final inputFile = new io.File(absolutePath);

    // Ensure the file exists
    if (!inputFile.existsSync()) {
      _addError(includeMacro.filePathToken, 'Could not find file.');
    } else {
      // Read the file
      final String fileContents = inputFile.readAsStringSync();

      // Parse the compile and compile macros
      final result = compileFileToLines(fileContents, inputFile.uri);

      // Add lines and errors
      lines.addAll(result.item1);
      errors.addAll(result.item2);
    }
  }

  @override
  void visitOnceMacro(ast.OnceMacro onceMacro) {
    // TODO: implement visitOnceMacro
  }

  void _addError(Token token, String message) {
    errors.add(AssembleError(token.sourceSpan, message));
  }
}