import 'displacement_operand.dart';
import 'displacement_operator.dart';

class Displacement {
  final DisplacementOperator $operator;
  final DisplacementOperand value;

  Displacement(this.$operator, this.value)
    : assert($operator != null && value != null);
}