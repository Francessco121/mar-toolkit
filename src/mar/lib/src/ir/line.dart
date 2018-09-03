import 'line_visitor.dart';

abstract class Line {
  String get comment;
  set comment(String value);

  void accept(LineVisitor visitor);
}