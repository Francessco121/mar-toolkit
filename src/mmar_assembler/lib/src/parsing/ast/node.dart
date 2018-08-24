import 'node_visitor.dart';

abstract class Node {
  void accept(NodeVisitor visitor);
}