import 'displacement_operand.dart';
import 'instruction_operand.dart';
import 'memory_operand.dart';

class ConstOperand implements
  DisplacementOperand, 
  InstructionOperand, 
  MemoryOperand 
{
  @override
  final int selector = 0x1F; // 0x1F = 0b1_1111 = IMMEDIATE16

  String get constIdentifier => _constIdentifier;

  set constIdentifier(String value) {
    assert(value != null);
    _constIdentifier = value;
  }

  String _constIdentifier;

  ConstOperand(String constIdentifier)
    : assert(constIdentifier != null),
      _constIdentifier = constIdentifier;
}