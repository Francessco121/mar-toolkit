/// The minimum value of an unsigned 16-bit value.
const int minUnsigned16BitValue = 0;
/// The maximum value of an unsigned 16-bit value.
const int maxUnsigned16BitValue = 65535;

/// Returns the sum of [left] and [right] within the bounds of a 16-bit number.
/// If the sum overflows or underflows, it will wrap around.
int $16BitAdd(int left, int right) {
  return _handleOverAndUnderflow(left + right);
}

/// Returns the difference of [left] and [right] within the bounds of a 16-bit number.
/// If the difference overflows or underflows, it will wrap around.
int $16BitSubtraction(int left, int right) {
  return _handleOverAndUnderflow(left - right);
}

int _handleOverAndUnderflow(int value) {
  if (value < minUnsigned16BitValue || value > maxUnsigned16BitValue) {
    // Just cut-off everything above 16-bits
    return value & 0xFFFF;
  } else {
    return value;
  }
}