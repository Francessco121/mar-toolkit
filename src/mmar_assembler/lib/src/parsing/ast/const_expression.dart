import 'package:meta/meta.dart';

import '../../scanning/token.dart';
import 'expression.dart';
import 'expression_visitor.dart';

@immutable
class ConstExpression implements Expression {
  final Expression left;
  final Token operator_;
  final Expression right;

  const ConstExpression({
    @required this.left,
    @required this.operator_,
    @required this.right
  })
    : assert(left != null),
      assert(operator_ != null),
      assert(right != null);

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitConstExpression(this);
  }
}

