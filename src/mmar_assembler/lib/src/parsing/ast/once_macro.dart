import 'package:meta/meta.dart';

import '../../scanning/token.dart';
import 'macro.dart';
import 'macro_visitor.dart';

@immutable
class OnceMacro implements Macro {
  @override
  final Token comment;
  
  final Token onceKeyword;

  const OnceMacro({
    @required this.onceKeyword,
    @required this.comment
  })
    : assert(onceKeyword != null);

  @override
  void accept(MacroVisitor visitor) {
    visitor.visitOnceMacro(this);
  }
}