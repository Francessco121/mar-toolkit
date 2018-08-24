import 'package:meta/meta.dart';

import '../scanning/token.dart';

@immutable
class ParseError {
  final Token token;
  final String message;

  const ParseError({
    @required this.token,
    @required this.message
  });
}