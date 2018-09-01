import 'dart:collection';
import 'dart:io' as io;

import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

import '../ast/ast.dart' as ast;
import '../token.dart';
import '../mmar_error.dart';
import '../mmar_program.dart';
import '../source_tree.dart';
import '../source.dart';
import 'parse.dart';
import 'scan.dart';

/// Compiles all macros in the given list of MMAR AST [statements],
/// resulting in a list of MMAR AST lines.
/// 
/// [source] - The source that the list of [statements] came from.
/// 
/// [sourceTreeNode] - The tree node of the [source] in the [program].
/// 
/// [program] - The program this [source] is a part of.
MacroCompileResult compileMacros(List<ast.Statement> statements, {
  @required Source source,
  @required SourceTreeNode sourceTreeNode,
  @required MmarProgram program
}) {
  assert(statements != null);
  assert(source != null);
  assert(sourceTreeNode != null);
  assert(program != null);

  final visitor = new _MacroVisitor(program, source, sourceTreeNode);

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
    lines: UnmodifiableListView(visitor.lines),
    errors: UnmodifiableListView(visitor.errors)
  );
}

class MacroCompileResult {
  final UnmodifiableListView<ast.Line> lines;
  final UnmodifiableListView<MmarError> errors;

  MacroCompileResult({
    @required this.lines,
    @required this.errors
  })
    : assert(lines != null),
      assert(errors != null);
}

class _MacroVisitor implements ast.MacroVisitor {
  bool _visitedInclude = false;

  final List<ast.Line> lines = [];
  final List<MmarError> errors = [];
  final MmarProgram _program;
  final Source _source;
  final SourceTreeNode _sourceTreeNode;

  /// The directory of the source file.
  final String _sourceDirectory;

  _MacroVisitor(this._program, Source source, SourceTreeNode sourceTreeNode)
    : assert(_program != null),
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
    if (!_program.sources.containsKey(includedUri)) {
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
      _program.sources[includedUri] = includedSource;

      // Create a source tree node
      final includedSourceNode = _sourceTreeNode.addChild(includedUri);

      // Scan the source
      final scanResult = scan(includedSource);

      // Parse the source
      final parseResult = parse(scanResult.tokens);

      // Compile the macros in the included file
      final macroCompileResult = compileMacros(parseResult.statements,
        source: includedSource,
        sourceTreeNode: includedSourceNode,
        program: _program
      );

      // Add the lines to the assembler state
      _program.sourceLines[includedUri] = macroCompileResult.lines;

      // Add lines and errors
      lines.addAll(macroCompileResult.lines);

      errors
        ..addAll(scanResult.errors)
        ..addAll(parseResult.errors)
        ..addAll(macroCompileResult.errors);
    } else {
      final includedSource = _program.sources[includedUri];

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
        final includedLines = _program.sourceLines[includedUri];
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
    errors.add(MmarError(token.sourceSpan, message));
  }
}