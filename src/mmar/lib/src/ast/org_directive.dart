import 'package:meta/meta.dart';

import '../token.dart';
import 'const_expression.dart';
import 'line.dart';
import 'line_visitor.dart';

@immutable
class OrgDirective implements Line {
  @override
  final Token comment;
  
  final Token orgKeyword;
  final ConstExpression expression;

  const OrgDirective({
    @required this.orgKeyword,
    @required this.expression,
    @required this.comment
  })
    : assert(orgKeyword != null),
      assert(expression != null);

  @override
  void accept(LineVisitor visitor) {
    visitor.visitOrgDirective(this);
  }
}