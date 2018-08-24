import 'package:meta/meta.dart';
import 'package:source_span/source_span.dart';

import 'token_type.dart';

@immutable
class Token {
  final TokenType type;
  final Object literal;
  final SourceSpan sourceSpan;

  Token({
    @required this.type,
    @required this.sourceSpan,
    this.literal = null
  })
    : assert(type != null),
      assert(sourceSpan != null);
}