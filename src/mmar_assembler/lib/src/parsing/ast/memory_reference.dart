import 'package:meta/meta.dart';

import '../../scanning/token.dart';
import 'const_expression.dart';
import 'instruction_operand.dart';

@immutable
class MemoryReference implements InstructionOperand {
  final Token leftBracket;
  final Token rightBracket;
  
  final ConstExpression value;

  final Token displacementOperator;
  final ConstExpression displacementValue;

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