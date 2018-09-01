import 'package:meta/meta.dart';

import '../token.dart';
import 'instruction_operand.dart';
import 'memory_value.dart';

@immutable
class MemoryReference implements InstructionOperand {
  final Token leftBracket;
  final Token rightBracket;
  
  final MemoryValue value;

  final Token displacementOperator;
  final MemoryValue displacementValue;

  const MemoryReference({
    @required this.leftBracket,
    @required this.rightBracket,
    @required this.value,
    @required this.displacementOperator,
    @required this.displacementValue
  })
    : assert(leftBracket != null),
      assert(rightBracket != null),
      assert(value != null);
}