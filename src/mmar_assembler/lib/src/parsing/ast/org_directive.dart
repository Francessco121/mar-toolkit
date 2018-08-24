import 'package:meta/meta.dart';

import '../../scanning/token.dart';
import 'expression.dart';
import 'node.dart';
import 'node_visitor.dart';

@immutable
class OrgDirective implements Node {
  final Token orgKeyword;
  final Expression expression;

  const OrgDirective({
    @required this.orgKeyword,
    @required this.expression
  })
    : assert(orgKeyword != null),
      assert(expression != null);

  @override
  void accept(NodeVisitor visitor) {
    visitor.visitOrgDirective(this);
  }
}