import 'package:meta/meta.dart';

import 'displacement_operand.dart';
import 'displacement_operator.dart';

@immutable
class Displacement {
  final DisplacementOperator $operator;
  final DisplacementOperand value;

  const Displacement(this.$operator, this.value)
    : assert($operator != null && value != null);
}