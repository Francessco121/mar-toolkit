import 'package:meta/meta.dart';

import '../../scanning/token.dart';
import 'expression.dart';
import 'label.dart';
import 'node.dart';
import 'node_visitor.dart';

@immutable
class DwDirective implements Node {
  final Label label;
  final Token dwToken;
  final List<Expression> expressions;

  const DwDirective({
    @required this.label,
    @required this.dwToken,
    @required this.expressions
  })
    : assert(dwToken != null),
      assert(expressions != null);

  @override
  void accept(NodeVisitor visitor) {
    visitor.visitDwDirective(this);
  }
}