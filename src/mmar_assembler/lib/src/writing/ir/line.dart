import 'line_visitor.dart';

abstract class Line {
  String get comment;

  void accept(LineVisitor visitor);
}