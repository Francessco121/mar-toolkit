import 'displacement_operand.dart';
import 'instruction_operand.dart';
import 'memory_operand.dart';

class ImmediateOperand implements 
  DisplacementOperand, 
  InstructionOperand, 
  MemoryOperand 
{
  @override
  final int selector = 0x1F; // 0x1F = 0b1_1111 = IMMEDIATE16

  final int value;

  ImmediateOperand(this.value);
}