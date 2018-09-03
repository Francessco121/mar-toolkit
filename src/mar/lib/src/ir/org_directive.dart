import 'line.dart';
import 'line_visitor.dart';

class OrgDirective implements Line {
  @override
  String comment;
  
  int get value => _value;

  set value(int value) {
    assert(value != null);
    _value = value;
  }

  int _value;

  OrgDirective(int value, {this.comment})
    : assert(value != null),
      _value = value;

  @override
  void accept(LineVisitor visitor) {
    visitor.visitOrgDirective(this);
  }
}