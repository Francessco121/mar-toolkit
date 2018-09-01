import 'package:meta/meta.dart';

import 'instruction_operand.dart';
import 'memory_operand.dart';
import 'register.dart';

@immutable
class RegisterOperand implements InstructionOperand, MemoryOperand {
  @override
  int get selector => registerIndexes[register];

  final Register register;

  const RegisterOperand(this.register);
}