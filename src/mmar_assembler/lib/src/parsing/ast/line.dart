import '../../scanning/token.dart';
import 'line_visitor.dart';

abstract class Line {
  Token get comment;

  void accept(LineVisitor visitor);
}