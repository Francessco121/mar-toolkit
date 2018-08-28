import 'line_visitor.dart';
import 'statement.dart';

abstract class Line extends Statement {
  void accept(LineVisitor visitor);
}