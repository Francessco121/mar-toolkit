import 'package:meta/meta.dart';

import '../../scanning/token.dart';
import 'expression.dart';
import 'expression_visitor.dart';

@immutable
class DwIntegerExpression implements Expression {
  final Expression leftExpression;
  final Token dupToken;
  final Expression dupExpression;

  const DwIntegerExpression({
    @required this.leftExpression,
    @required this.dupToken,
    @required this.dupExpression
  })
    : assert(leftExpression != null),
      assert(dupToken != null),
      assert(dupExpression != null);

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitDwIntegerExpression(this);
  }
}