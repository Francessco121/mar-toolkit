import 'package:meta/meta.dart';

import 'line.dart';
import 'line_visitor.dart';

@immutable
class Comment implements Line {
  @override
  final String comment;

  const Comment(this.comment);

  @override
  void accept(LineVisitor visitor) {
    visitor.visitComment(this);
  }
}