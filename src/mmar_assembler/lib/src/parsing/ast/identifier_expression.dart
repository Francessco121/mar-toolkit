import 'package:meta/meta.dart';

import '../../scanning/token.dart';
import 'const_expression.dart';
import 'const_expression_visitor.dart';

@immutable
class IdentifierExpression implements ConstExpression {
  final Token identifier;

  const IdentifierExpression({
    @required this.identifier
  })
    : assert(identifier != null);

  @override
  int accept(ConstExpressionVisitor visitor) {
    return visitor.visitIdentifierExpression(this);
  }
}