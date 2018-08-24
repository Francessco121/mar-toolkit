import 'package:meta/meta.dart';

import '../../scanning/token.dart';
import 'expression.dart';
import 'expression_visitor.dart';

@immutable
class MemoryExpression implements Expression {
  final Token leftBracket;
  final Token rightBracket;
  
  final Expression value;

  final Token displacementOperator;
  final Expression displacementValue;

  const MemoryExpression({
    @required this.leftBracket,
    @required this.rightBracket,
    @required this.value,
    @required this.displacementOperator,
    @required this.displacementValue
  })
    : assert(leftBracket != null),
      assert(rightBracket != null),
      assert(value != null);

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitMemoryExpression(this);
  }
}