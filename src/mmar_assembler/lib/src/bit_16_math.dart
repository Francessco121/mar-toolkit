/// The minimum value of an unsigned 16-bit value.
const int minUnsigned16BitValue = 0;
/// The maximum value of an unsigned 16-bit value.
const int maxUnsigned16BitValue = 65535;

/// Converts the given [value] to an unsigned 16-bit integer
/// (still represented by Dart's 64-bit `int`) by removing
/// higher bits if needed.
int toUnsigned16BitInteger(int value) {
  if (value < minUnsigned16BitValue || value > maxUnsigned16BitValue) {
    return value & 0xFFFF;
  } else {
    return value;
  }
}
