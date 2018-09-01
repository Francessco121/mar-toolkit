import 'line.dart';
import 'line_visitor.dart';

class Constant implements Line {
  @override
  final String comment;
  
  final String identifier;
  final int value;

  Constant(this.identifier, this.value, {this.comment});

  @override
  void accept(LineVisitor visitor) {
    visitor.visitConstant(this);
  }
}