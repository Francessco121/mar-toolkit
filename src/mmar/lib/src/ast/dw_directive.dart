import 'package:meta/meta.dart';

import '../token.dart';
import 'dw_operand.dart';
import 'label.dart';
import 'line.dart';
import 'line_visitor.dart';

@immutable
class DwDirective implements Line {
  @override
  final Token comment;
  
  final Label label;
  final Token dwToken;
  final List<DwOperand> operands;

  const DwDirective({
    @required this.label,
    @required this.dwToken,
    @required this.operands,
    @required this.comment
  })
    : assert(dwToken != null),
      assert(operands != null);

  @override
  void accept(LineVisitor visitor) {
    visitor.visitDwDirective(this);
  }
}