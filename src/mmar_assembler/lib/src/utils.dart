import 'package:tuple/tuple.dart';

import 'compiling/macro_compiler.dart';
import 'parsing/ast/ast.dart' as ast;
import 'parsing/parser.dart';
import 'scanning/scanner.dart';
import 'assemble_error.dart';
import 'assembler_state.dart';
import 'source.dart';
import 'source_tree.dart';

Tuple2<List<ast.Line>, List<AssembleError>> compileFileToLines(
  Source source, SourceTreeNode sourceTreeNode, AssemblerState state
) {
  assert(source != null);
  assert(sourceTreeNode != null);
  assert(state != null);

  final List<AssembleError> aggregatedErrors = [];

  // Scan the file
  final scanner = new Scanner(source);
  final ScanResult scanResult = scanner.scan();

  aggregatedErrors.addAll(scanResult.errors);

  // Parse the tokens
  final parser = new Parser(scanResult.tokens);
  final ParseResult parseResult = parser.parse();

  aggregatedErrors.addAll(parseResult.errors);

  // Compile macros
  final macroCompiler = new MacroCompiler(
    source: source,
    sourceTreeNode: sourceTreeNode, 
    statements: parseResult.statements,
    assemblerState: state
  );

  final MacroCompileResult macroCompileResult = macroCompiler.compile();

  aggregatedErrors.addAll(macroCompileResult.errors);

  // All set
  return Tuple2<List<ast.Line>, List<AssembleError>>(
    macroCompileResult.lines,
    aggregatedErrors
  );
}