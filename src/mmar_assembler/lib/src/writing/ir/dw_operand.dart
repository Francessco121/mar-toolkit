import 'package:meta/meta.dart';

@immutable
class DwOperand {
  final int value;
  /// Can be `null`.
  final int duplicate;

  const DwOperand(this.value, {this.duplicate});
}