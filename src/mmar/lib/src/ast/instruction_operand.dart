import 'package:meta/meta.dart';

import 'const_expression.dart';

abstract class InstructionOperand { }

@immutable
class InstructionExpressionOperand implements InstructionOperand {
  final ConstExpression expression;

  const InstructionExpressionOperand(this.expression)
    : assert(expression != null);
}