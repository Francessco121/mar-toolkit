import 'package:meta/meta.dart';

import 'dw_operand.dart';
import 'labelable.dart';
import 'line.dart';
import 'line_visitor.dart';

@immutable
class DwDirective implements Labelable, Line {
  @override
  final String comment;
  
  @override
  final String label;

  final List<DwOperand> operands;

  const DwDirective(this.operands, {this.label, this.comment});

  @override
  void accept(LineVisitor visitor) {
    visitor.visitDwDirective(this);
  }
}