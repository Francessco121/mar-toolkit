import 'package:meta/meta.dart';

import '../token.dart';
import 'literal_expression.dart';

@immutable
class StringLiteral implements LiteralExpression {
  final Token token;
  final String value;

  const StringLiteral({
    @required this.token,
    @required this.value
  })
    : assert(token != null),
      assert(value != null);
}