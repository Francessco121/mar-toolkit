import 'package:meta/meta.dart';

import 'instruction_operand.dart';
import 'memory_operand.dart';
import 'register.dart';

@immutable
class RegisterOperand implements InstructionOperand, MemoryOperand {
  final Register register;

  const RegisterOperand(this.register);
}