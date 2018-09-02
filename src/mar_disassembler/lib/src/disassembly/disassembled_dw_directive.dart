import 'package:mar/mar.dart';

import 'disassembled_content.dart';
import 'disassembled_content_visitor.dart';

class DisassembledDwDirective implements DisassembledContent {
  final List<DwOperand> operands;

  DisassembledDwDirective(this.operands);

  @override
  void accept(DisassembledContentVisitor visitor) {
    visitor.visitDwDirective(this);
  }
}