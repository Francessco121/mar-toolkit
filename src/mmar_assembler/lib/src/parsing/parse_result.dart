import 'package:meta/meta.dart';

import 'ast/ast.dart' as ast;
import 'parse_error.dart';

@immutable
class ParseResult {
  final List<ParseError> errors;
  final List<ast.Line> lines;

  const ParseResult({
    @required this.lines,
    @required this.errors
  });
}