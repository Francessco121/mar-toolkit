import 'package:meta/meta.dart';

import 'scan_error.dart';
import 'token.dart';

@immutable
class ScanResult {
  final List<ScanError> errors;
  final List<Token> tokens;

  const ScanResult({
    @required this.tokens,
    @required this.errors
  });
}