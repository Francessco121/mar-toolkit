import 'line.dart';
import 'line_visitor.dart';

class Comment implements Line {
  @override
  final String comment;

  Comment(this.comment);

  @override
  void accept(LineVisitor visitor) {
    visitor.visitComment(this);
  }
}