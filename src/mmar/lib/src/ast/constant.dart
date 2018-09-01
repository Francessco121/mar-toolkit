import 'package:meta/meta.dart';

import '../token.dart';
import 'const_expression.dart';
import 'line.dart';
import 'line_visitor.dart';

@immutable
class Constant implements Line {
  @override
  final Token comment;
  
  final Token identifier;
  final Token equToken;
  final ConstExpression expression;

  const Constant({
    @required this.identifier,
    @required this.equToken,
    @required this.expression,
    @required this.comment
  })
    : assert(identifier != null),
      assert(equToken != null),
      assert(expression != null);

  @override
  void accept(LineVisitor visitor) {
    visitor.visitConstant(this);
  }
}

