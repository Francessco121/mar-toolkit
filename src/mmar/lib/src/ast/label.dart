import 'package:meta/meta.dart';

import '../token.dart';

@immutable
class Label {
  final Token identifier;
  final Token colonToken;

  const Label({
    @required this.identifier,
    @required this.colonToken
  })
    : assert(identifier != null),
      assert(colonToken != null);
}