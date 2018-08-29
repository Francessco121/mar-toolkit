import 'package:meta/meta.dart';

import '../../scanning/token.dart';
import 'const_expression.dart';
import 'const_expression_visitor.dart';

@immutable
class ConstUnaryExpression implements ConstExpression {
  final Token $operator;
  final ConstExpression expression;

  const ConstUnaryExpression({
    @required this.$operator,
    @required this.expression
  })
    : assert($operator != null),
      assert(expression != null);

  @override
  int accept(ConstExpressionVisitor visitor) {
    return visitor.visitConstUnaryExpression(this);
  }
}

