import 'package:meta/meta.dart';

import '../writing/ir/ir.dart' as ir;
import 'ast_compile_error.dart';

@immutable
class AstCompileResult {
  final List<ir.Line> lines;
  final List<AstCompileError> errors;

  const AstCompileResult({
    @required this.lines,
    @required this.errors
  })
    : assert(lines != null),
      assert(errors != null);
}