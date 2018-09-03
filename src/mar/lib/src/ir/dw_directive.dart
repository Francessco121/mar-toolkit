import 'dw_operand.dart';
import 'labelable.dart';
import 'line.dart';
import 'line_visitor.dart';

class DwDirective implements Labelable, Line {
  @override
  String comment;
  
  @override
  String label;

  final List<DwOperand> operands;

  DwDirective(this.operands, {this.label, this.comment});

  @override
  void accept(LineVisitor visitor) {
    visitor.visitDwDirective(this);
  }
}