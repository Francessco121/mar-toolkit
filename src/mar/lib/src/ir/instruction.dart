import '../mnemonic.dart';
import 'instruction_operand.dart';
import 'labelable.dart';
import 'line.dart';
import 'line_visitor.dart';

class Instruction implements Labelable, Line {
  @override
  String comment;
  
  @override
  String label;

  Mnemonic get mnemonic => _mnemonic;

  set mnemonic(Mnemonic value) {
    assert(value != null);
    _mnemonic = value;
  }

  InstructionOperand operand1;
  InstructionOperand operand2;

  Mnemonic _mnemonic;

  Instruction(Mnemonic mnemonic, {
    this.operand1,
    this.operand2,
    this.label, 
    this.comment
  }) 
    : assert(mnemonic != null),
      _mnemonic = mnemonic
  {
    // If operand2 was specified, operand1 must exist
    assert(operand2 == null || operand1 != null);
  }

  @override
  void accept(LineVisitor visitor) {
    visitor.visitInstruction(this);
  }
}