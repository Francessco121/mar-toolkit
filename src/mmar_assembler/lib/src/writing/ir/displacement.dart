import 'package:meta/meta.dart';

import 'displacement_operand.dart';
import 'displacement_operator.dart';

@immutable
class Displacement {
  final DisplacementOperator operator_;
  final DisplacementOperand value;

  const Displacement(this.operator_, this.value)
    : assert(operator_ != null && value != null);
}