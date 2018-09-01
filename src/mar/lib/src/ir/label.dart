import 'labelable.dart';
import 'line.dart';
import 'line_visitor.dart';

class Label implements Labelable, Line {
  @override
  final String comment;

  @override
  final String label;

  Label(this.label, {this.comment});

  @override
  void accept(LineVisitor visitor) {
    visitor.visitLabel(this);
  }
}