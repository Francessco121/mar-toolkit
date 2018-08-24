import 'package:meta/meta.dart';

import '../../scanning/token.dart';
import 'node.dart';
import 'node_visitor.dart';

@immutable
class Label implements Node {
  final Token identifier;
  final Token colonToken;

  const Label({
    @required this.identifier,
    @required this.colonToken
  })
    : assert(identifier != null),
      assert(colonToken != null);

  @override
  void accept(NodeVisitor visitor) {
    visitor.visitLabel(this);
  }
}