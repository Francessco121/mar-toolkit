import 'package:meta/meta.dart';

import '../../scanning/token.dart';
import 'node.dart';
import 'node_visitor.dart';

@immutable
class Line implements Node {
  final Node innerNode;
  final Token comment;

  const Line({
    @required this.innerNode,
    @required this.comment
  })
    : assert(innerNode != null || comment != null);

  @override
  void accept(NodeVisitor visitor) {
    visitor.visitLine(this);
  }
}