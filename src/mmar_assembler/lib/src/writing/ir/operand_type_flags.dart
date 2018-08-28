import 'const_operand.dart';
import 'immediate_operand.dart';
import 'instruction_operand.dart';
import 'label_operand.dart';
import 'memory_instruction_operand.dart';
import 'register_operand.dart';

const int memoryOp = 0x0001;
const int registerOp = 0x0010;
const int immediateOp = 0x0100;
const int noOp = 0x1000;

String operandTypeFlagToString(int type) {
  switch (type) {
    case immediateOp:
      return 'immediate';
    case memoryOp:
      return 'memory';
    case registerOp:
      return 'register';
    case noOp:
      return 'nothing';
  }

  throw ArgumentError.value(type, 'type');
}

int operandToTypeFlag(InstructionOperand operand) {
  if (operand == null) {
    return noOp;
  }

  if (operand is ImmediateOperand) {
    return immediateOp;
  } else if (operand is MemoryInstructionOperand) {
    return memoryOp;
  } else if (operand is RegisterOperand) {
    return registerOp;
  } else if (operand is LabelOperand) {
    return immediateOp;
  } else if (operand is ConstOperand) {
    return immediateOp;
  }

  throw new ArgumentError.value(operand, 'operand');
}