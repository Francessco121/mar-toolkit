import 'const_expression.dart';
import 'dw_integer_expression.dart';
import 'identifier_expression.dart';
import 'literal_expression.dart';
import 'memory_expression.dart';

abstract class ExpressionVisitor<T> {
  T visitConstExpression(ConstExpression expression);
  T visitDwIntegerExpression(DwIntegerExpression dwIntegerExpression);
  T visitIdentifierExpression(IdentifierExpression identifierExpression);
  T visitLiteralExpression(LiteralExpression literalExpression);
  T visitMemoryExpression(MemoryExpression memoryExpression);
}