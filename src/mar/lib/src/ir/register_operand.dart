import 'instruction_operand.dart';
import 'memory_operand.dart';
import 'register.dart';

class RegisterOperand implements InstructionOperand, MemoryOperand {
  @override
  int get selector => registerIndexes[register];

  final Register register;

  RegisterOperand(this.register);
}