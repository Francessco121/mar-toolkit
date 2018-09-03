import '../register.dart';
import 'instruction_operand.dart';
import 'memory_operand.dart';

class RegisterOperand implements InstructionOperand, MemoryOperand {
  @override
  int get selector => registerIndexes[register];

  Register get register => _register;

  set register(Register value) {
    assert(value != null);
    _register = value;
  }

  Register _register;

  RegisterOperand(Register register)
    : assert(register != null),
      _register = register;
}