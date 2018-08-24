import 'package:meta/meta.dart';

import '../../scanning/token.dart';
import 'expression.dart';
import 'node.dart';
import 'node_visitor.dart';

@immutable
class Constant implements Node {
  final Token identifier;
  final Token equToken;
  final Expression expression;

  const Constant({
    @required this.identifier,
    @required this.equToken,
    @required this.expression
  })
    : assert(identifier != null),
      assert(equToken != null),
      assert(expression != null);

  @override
  void accept(NodeVisitor visitor) {
    visitor.visitConstant(this);
  }
}

