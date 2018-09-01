import 'package:meta/meta.dart';

import '../token.dart';
import 'instruction_operand.dart';
import 'label.dart';
import 'line.dart';
import 'line_visitor.dart';

@immutable
class Instruction implements Line {
  @override
  final Token comment;
  
  final Label label;
  final Token mnemonic;
  final InstructionOperand operand1;
  final Token commaToken;
  final InstructionOperand operand2;

  const Instruction({
    @required this.label,
    @required this.mnemonic,
    @required this.operand1,
    @required this.commaToken,
    @required this.operand2,
    @required this.comment
  })
    : assert(mnemonic != null);

  @override
  void accept(LineVisitor visitor) {
    visitor.visitInstruction(this);
  }
}