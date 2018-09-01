import 'line.dart';
import 'line_visitor.dart';

class OrgDirective implements Line {
  @override
  final String comment;
  
  final int value;

  OrgDirective(this.value, {this.comment});

  @override
  void accept(LineVisitor visitor) {
    visitor.visitOrgDirective(this);
  }
}