import 'dart:io' as io
;
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

import '../parsing/ast/ast.dart' as ast;
import '../scanning/token.dart';
import '../assemble_error.dart';
import '../assembler_state.dart';
import '../source_tree.dart';
import '../source.dart';
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
  bool _compiled = false;

  final AssemblerState _assemblerState;
  final Source _source;
  final SourceTreeNode _sourceTreeNode;
  final List<ast.Statement> _statements;

  MacroCompiler({
    @required AssemblerState assemblerState,
    @required Source source,
    @required SourceTreeNode sourceTreeNode,
    @required List<ast.Statement> statements
  })
    : assert(assemblerState != null),
      assert(source != null),
      assert(sourceTreeNode != null),
      assert(statements != null),
      _assemblerState = assemblerState,
      _source = source,
      _sourceTreeNode = sourceTreeNode,
      _statements = statements;

  MacroCompileResult compile() {
    if (_compiled) {
      throw StateError('This macro compiler has already been ran.');
    }

    _compiled = true;

    final visitor = new _MacroVisitor(_assemblerState, _source, _sourceTreeNode);

    for (var statement in _statements) {
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
  bool _visitedInclude = false;

  final List<ast.Line> lines = [];
  final List<AssembleError> errors = [];
  final AssemblerState _assemblerState;
  final Source _source;
  final SourceTreeNode _sourceTreeNode;

  /// The directory of the source file.
  final String _sourceDirectory;

  _MacroVisitor(this._assemblerState, Source source, SourceTreeNode sourceTreeNode)
    : assert(_assemblerState != null),
      assert(source != null),
      assert(sourceTreeNode != null),
      _source = source,
      _sourceTreeNode = sourceTreeNode,
      _sourceDirectory = path.dirname(path.fromUri(sourceTreeNode.uri));

  void visitLine(ast.Line line) {
    lines.add(line);
  }

  @override
  void visitIncludeMacro(ast.IncludeMacro includeMacro) {
    _visitedInclude = true;

    // Convert the included relative file path into an absolute path
    final String relativefilePath = includeMacro.filePathToken.literal;
    final String absolutePath = path.normalize(path.join(_sourceDirectory, relativefilePath));
    
    // Convert the absolute path into a file URI
    final Uri includedUri = Uri.file(absolutePath, windows: io.Platform.isWindows);

    // Ensure this source is not including itself
    if (includedUri == _source.uri) {
      _addError(includeMacro.filePathToken, 'Source file cannot include itself.');
      return;
    }

    // Check if the file has already been loaded
    if (!_assemblerState.sources.containsKey(includedUri)) {
      // Load the file for the first time
      final inputFile = new io.File.fromUri(includedUri);

      // Ensure the file exists
      if (!inputFile.existsSync()) {
        _addError(includeMacro.filePathToken, 'Could not find file.');
        return;
      }

      // Read the file
      final String fileContents = inputFile.readAsStringSync();
      final includedSource = Source(includedUri, fileContents);

      // Add the source to the assembler state
      _assemblerState.sources[includedUri] = includedSource;

      // Create a source tree node
      final includedSourceNode = _sourceTreeNode.addChild(includedUri);

      // Parse the file and compile macros
      final result = compileFileToLines(includedSource, includedSourceNode, _assemblerState);

      // Add the lines to the assembler state
      _assemblerState.sourceLines[includedUri] = result.item1;

      // Add lines and errors
      lines.addAll(result.item1);
      errors.addAll(result.item2);
    } else {
      final includedSource = _assemblerState.sources[includedUri];

      // Ignore the include if the included source was marked with the once macro
      // and has already been parsed and had its macros compiled.
      if (!includedSource.includedOnce) {
        // Check for a cyclic include
        final cyclicParent = _sourceTreeNode.getAncestor(includedUri);
        if (cyclicParent != null) {
          _addCyclicIncludeError(includeMacro, includedUri, cyclicParent);
          return;
        }
        
        // Get the existing AST lines since the included source has already been parsed
        // and had its macros compiled.
        final includedLines = _assemblerState.sourceLines[includedUri];
        assert(includedLines != null);

        // Insert the existing lines
        lines.addAll(includedLines);
      }
    }
  }

  @override
  void visitOnceMacro(ast.OnceMacro onceMacro) {
    if (_visitedInclude) {
      _addError(onceMacro.onceKeyword, "The 'once' macro cannot appear after an 'include' macro.");
      return;
    } 

    if (_source.includedOnce) {
      _addError(onceMacro.onceKeyword, "Source files may only have one 'once' macro.");
      return;
    }

    _source.setIncludedOnce();
  }

  void _addCyclicIncludeError(ast.IncludeMacro includeMacro, Uri includedUri, SourceTreeNode cyclicParent) {
    final buffer = StringBuffer();
    buffer.writeln('Include would result in cyclic dependencies because');
    buffer.writeln('it includes $includedUri,');

    final Iterable<SourceTreeNode> ancestors = _sourceTreeNode
      .getAncestors(untilSourceUri: cyclicParent.uri)
      .reversed;

    for (final SourceTreeNode ancestor in ancestors) {
      buffer.writeln('which includes ${ancestor.uri},');
    }

    buffer.write('which includes ${_source.uri}.');

    _addError(includeMacro.filePathToken, buffer.toString());
  }

  void _addError(Token token, String message) {
    errors.add(AssembleError(token.sourceSpan, message));
  }
}