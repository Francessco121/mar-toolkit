import 'package:meta/meta.dart';

import '../../scanning/token.dart';
import 'expression.dart';
import 'expression_visitor.dart';

@immutable
class IdentifierExpression implements Expression {
  final Token identifier;

  const IdentifierExpression({
    @required this.identifier
  })
    : assert(identifier != null);

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitIdentifierExpression(this);
  }
}