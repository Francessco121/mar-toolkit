import 'package:meta/meta.dart';

import 'instruction_operand.dart';
import 'labelable.dart';
import 'line.dart';
import 'line_visitor.dart';
import 'mnemonic.dart';

@immutable
class Instruction implements Labelable, Line {
  final String comment;
  final String label;
  final Mnemonic mnemonic;
  final InstructionOperand operand1;
  final InstructionOperand operand2;

  const Instruction(this.mnemonic, {
    this.operand1,
    this.operand2,
    this.label, 
    this.comment
  });

  @override
  void accept(LineVisitor visitor) {
    visitor.visitInstruction(this);
  }
}