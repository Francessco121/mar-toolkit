import 'package:meta/meta.dart';

import '../../scanning/token.dart';
import 'expression.dart';
import 'expression_visitor.dart';

@immutable
class LiteralExpression implements Expression {
  final Token token;
  final Object value;

  const LiteralExpression({
    @required this.token,
    @required this.value
  })
    : assert(token != null);

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitLiteralExpression(this);
  }
}