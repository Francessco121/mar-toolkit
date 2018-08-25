import 'const_binary_expression.dart';
import 'identifier_expression.dart';
import 'integer_expression.dart';

abstract class ConstExpressionVisitor {
  int visitConstBinaryExpression(ConstBinaryExpression expression);
  int visitIdentifierExpression(IdentifierExpression identifierExpression);
  int visitIntegerExpression(IntegerExpression integerExpression);
}