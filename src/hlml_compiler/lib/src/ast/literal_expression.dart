import '../token.dart';
import 'expression.dart';
import 'expression_visitor.dart';
import 'literal_type.dart';

class LiteralExpression implements Expression {
  final LiteralType type;
  final Object value;
  final Token token;

  LiteralExpression(this.type, this.value, this.token) {
    if (type == null) throw ArgumentError.notNull('type');
    if (value == null) throw ArgumentError.notNull('value');
    if (token == null) throw ArgumentError.notNull('token');
  }

  @override
  T accept<T>(ExpressionVisitor<T> visitor) {
    return visitor.visitLiteral(this);
  }
}