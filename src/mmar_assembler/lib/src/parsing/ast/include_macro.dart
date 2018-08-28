import 'package:meta/meta.dart';

import '../../scanning/token.dart';
import 'macro.dart';
import 'macro_visitor.dart';

@immutable
class IncludeMacro implements Macro {
  @override
  final Token comment;
  
  final Token includeKeyword;
  final Token filePathToken;

  const IncludeMacro({
    @required this.includeKeyword,
    @required this.filePathToken,
    @required this.comment
  })
    : assert(includeKeyword != null),
      assert(filePathToken != null);

  @override
  void accept(MacroVisitor visitor) {
    visitor.visitIncludeMacro(this);
  }
}