import 'literal_expression.dart';

abstract class ExpressionVisitor<T> {
  T visitLiteral(LiteralExpression literal);
}