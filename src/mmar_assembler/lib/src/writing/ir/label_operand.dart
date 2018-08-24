import 'package:meta/meta.dart';

import 'displacement_operand.dart';
import 'instruction_operand.dart';
import 'memory_operand.dart';

@immutable
class LabelOperand implements
  DisplacementOperand, 
  InstructionOperand, 
  MemoryOperand 
{
  final String labelIdentifier;

  const LabelOperand(this.labelIdentifier);
}