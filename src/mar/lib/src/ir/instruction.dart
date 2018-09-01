import '../mnemonic.dart';
import 'instruction_operand.dart';
import 'labelable.dart';
import 'line.dart';
import 'line_visitor.dart';

class Instruction implements Labelable, Line {
  @override
  final String comment;
  
  @override
  final String label;

  final Mnemonic mnemonic;
  final InstructionOperand operand1;
  final InstructionOperand operand2;

  Instruction(this.mnemonic, {
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