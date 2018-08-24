import 'package:meta/meta.dart';

import 'displacement.dart';
import 'instruction_operand.dart';
import 'memory_operand.dart';

@immutable
class MemoryInstructionOperand implements InstructionOperand {
  final MemoryOperand value;
  final Displacement displacement;

  const MemoryInstructionOperand(this.value, {this.displacement})
    : assert(value != null);
}