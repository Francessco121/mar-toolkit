import 'package:meta/meta.dart';

@immutable
class DwOperand {
  /// Will either be an `int` or `String`.
  final dynamic value;
  /// Can be `null`.
  final int duplicate;

  /// [value] must be an `int` or `String`.
  DwOperand(this.value, {this.duplicate}) {
    assert(value != null && (value is int || value is String));
  }
}