import 'package:meta/meta.dart';

import '../../scanning/token.dart';
import 'const_expression.dart';
import 'const_expression_visitor.dart';

@immutable
class ConstGroupExpression implements ConstExpression {
  final Token leftParen;
  final ConstExpression expression;
  final Token rightParen;

  const ConstGroupExpression({
    @required this.leftParen,
    @required this.expression,
    @required this.rightParen
  })
    : assert(leftParen != null),
      assert(expression != null),
      assert(rightParen != null);

  @override
  int accept(ConstExpressionVisitor visitor) {
    return visitor.visitConstGroupExpression(this);
  }
}