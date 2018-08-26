import 'package:meta/meta.dart';

import 'displacement_operand.dart';
import 'instruction_operand.dart';
import 'memory_operand.dart';

@immutable
class ConstOperand implements
  DisplacementOperand, 
  InstructionOperand, 
  MemoryOperand 
{
  final String constIdentifier;

  const ConstOperand(this.constIdentifier);
}