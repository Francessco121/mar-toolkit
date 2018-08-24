import 'package:meta/meta.dart';

import 'displacement_operand.dart';
import 'instruction_operand.dart';
import 'memory_operand.dart';

@immutable
class ImmediateOperand implements 
  DisplacementOperand, 
  InstructionOperand, 
  MemoryOperand 
{
  final int value;

  const ImmediateOperand(this.value);
}