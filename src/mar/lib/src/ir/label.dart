import 'labelable.dart';
import 'line.dart';
import 'line_visitor.dart';

class Label implements Labelable, Line {
  @override
  String comment;

  @override
  String get label => _label;
  
  @override
  set label(String value) {
    assert(value != null);
    _label = value;
  }

  String _label;

  Label(String label, {this.comment})
    : assert(label != null),
      _label = label;

  @override
  void accept(LineVisitor visitor) {
    visitor.visitLabel(this);
  }
}