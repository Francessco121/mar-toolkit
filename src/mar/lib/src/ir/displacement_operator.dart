enum DisplacementOperator {
  plus,
  minus
}

String displacementOperatorToString(DisplacementOperator op) {
  switch (op) {
    case DisplacementOperator.plus: return '+';
    case DisplacementOperator.minus: return '-';
  }

  // Should never happen
  throw new ArgumentError.value(op, 'op');
}