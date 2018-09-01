import 'package:meta/meta.dart';

import '../token.dart';
import 'const_expression.dart';
import 'const_expression_visitor.dart';
import 'memory_value.dart';

@immutable
class IntegerExpression implements ConstExpression, MemoryValue {
  final Token token;
  final int value;

  const IntegerExpression({
    @required this.token,
    @required this.value
  })
    : assert(token != null),
      assert(value != null);

  @override
  int accept(ConstExpressionVisitor visitor) {
    return visitor.visitIntegerExpression(this);
  }
}