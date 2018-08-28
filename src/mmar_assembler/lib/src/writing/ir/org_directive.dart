import 'package:meta/meta.dart';

import 'line.dart';
import 'line_visitor.dart';

@immutable
class OrgDirective implements Line {
  @override
  final String comment;
  
  final int value;

  const OrgDirective(this.value, {this.comment});

  @override
  void accept(LineVisitor visitor) {
    visitor.visitOrgDirective(this);
  }
}