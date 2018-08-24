import 'package:meta/meta.dart';

import '../../scanning/token.dart';
import 'node.dart';
import 'node_visitor.dart';

@immutable
class Section implements Node {
  final Token dotToken;
  final Token identifier;

  const Section({
    @required this.dotToken,
    @required this.identifier
  })
    : assert(dotToken != null),
      assert(identifier != null);

  @override
  void accept(NodeVisitor visitor) {
    visitor.visitSection(this);
  }
}