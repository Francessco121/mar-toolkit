import 'package:tuple/tuple.dart';

import 'compiling/macro_compiler.dart';
import 'parsing/ast/ast.dart' as ast;
import 'parsing/parser.dart';
import 'scanning/scanner.dart';
import 'assemble_error.dart';

Tuple2<List<ast.Line>, List<AssembleError>> compileFileToLines(String fileContents, Uri fileUri) {
  assert(fileContents != null);
  assert(fileUri != null);

  final List<AssembleError> aggregatedErrors = [];

  // Scan the file
  final scanner = new Scanner(fileContents, fileUri);
  final ScanResult scanResult = scanner.scan();

  aggregatedErrors.addAll(scanResult.errors);

  // Parse the tokens
  final parser = new Parser(scanResult.tokens);
  final ParseResult parseResult = parser.parse();

  aggregatedErrors.addAll(parseResult.errors);

  // Compile macros
  final macroCompiler = new MacroCompiler();
  final MacroCompileResult macroCompileResult = macroCompiler.compile(parseResult.statements, fileUri);

  aggregatedErrors.addAll(macroCompileResult.errors);

  // All set
  return Tuple2<List<ast.Line>, List<AssembleError>>(
    macroCompileResult.lines,
    aggregatedErrors
  );
}