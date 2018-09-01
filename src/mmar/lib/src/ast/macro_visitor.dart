import 'include_macro.dart';
import 'once_macro.dart';

abstract class MacroVisitor {
  void visitIncludeMacro(IncludeMacro includeMacro);
  void visitOnceMacro(OnceMacro onceMacro);
}