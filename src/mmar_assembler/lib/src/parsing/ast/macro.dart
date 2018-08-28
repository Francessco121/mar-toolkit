import 'statement.dart';
import 'macro_visitor.dart';

abstract class Macro extends Statement {
  void accept(MacroVisitor visitor);
}