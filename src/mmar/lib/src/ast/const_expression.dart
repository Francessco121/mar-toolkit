import 'const_expression_visitor.dart';
import 'literal_expression.dart';

abstract class ConstExpression implements LiteralExpression {
  int accept(ConstExpressionVisitor visitor);
}