import 'package:mar/mar.dart';

import 'disassembled_content.dart';
import 'disassembled_content_visitor.dart';

class DisassembledInstruction implements DisassembledContent {
  final Mnemonic mnemonic;
  final InstructionOperand operand1;
  final InstructionOperand operand2;

  DisassembledInstruction(this.mnemonic, {
    this.operand1,
    this.operand2
  });

  @override
  void accept(DisassembledContentVisitor visitor) {
    visitor.visitInstruction(this);
  }
}