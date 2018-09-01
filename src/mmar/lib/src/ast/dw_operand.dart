import 'package:meta/meta.dart';

import '../token.dart';
import 'const_expression.dart';
import 'literal_expression.dart';

@immutable
class DwOperand {
  final LiteralExpression value;
  final Token dupToken;
  final ConstExpression duplicate;

  const DwOperand({
    @required this.value,
    @required this.dupToken,
    @required this.duplicate
  })
    : assert(value != null);
}