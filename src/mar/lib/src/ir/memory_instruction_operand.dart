import 'const_operand.dart';
import 'displacement.dart';
import 'immediate_operand.dart';
import 'instruction_operand.dart';
import 'label_operand.dart';
import 'memory_operand.dart';
import 'register_operand.dart';

class MemoryInstructionOperand implements InstructionOperand {
  @override
  int get selector {
    if (displacement == null) {
      if (value is ImmediateOperand || value is LabelOperand || value is ConstOperand) {
        return 0x1E; // 0x1E = 0b1_1110 = MEMORY_IMM16
      } else {
        final RegisterOperand registerOperand = value;

        // 0x8 = 0b1000
        // offset register index with 0x8 to form MEMORY_REG16
        return 0x8 + registerOperand.selector;
      }
    } else {
      final RegisterOperand registerOperand = value;

      // 0x10 = 0b1_0000
      // offset register index with 0x10 to form MEMORY_REG_DISP16
      return 0x10 + registerOperand.selector;
    }
  }

  final MemoryOperand value;
  final Displacement displacement;

  MemoryInstructionOperand(this.value, {this.displacement})
    : assert(value != null);
}