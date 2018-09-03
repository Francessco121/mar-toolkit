import 'displacement_operand.dart';
import 'instruction_operand.dart';
import 'memory_operand.dart';

class LabelOperand implements
  DisplacementOperand, 
  InstructionOperand, 
  MemoryOperand 
{
  @override
  final int selector = 0x1F; // 0x1F = 0b1_1111 = IMMEDIATE16

  String get labelIdentifier => _labelIdentifier;

  set labelIdentifier(String value) {
    assert(value != null);
    _labelIdentifier = value;
  }

  String _labelIdentifier;

  LabelOperand(String labelIdentifier)
    : assert(labelIdentifier != null),
      _labelIdentifier = labelIdentifier;
}