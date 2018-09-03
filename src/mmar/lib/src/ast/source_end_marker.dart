import '../token.dart';
import 'line_visitor.dart';
import 'line.dart';

/// A special AST line representing the end of a source.
/// 
/// For a program with multiple files, these will act as 
/// separators so the AST compiler can know when a new 
/// 'source' context has been left.
class SourceEndMarker implements Line {
  @override
  // ignore: avoid_field_initializers_in_const_classes
  final Token comment = null;

  const SourceEndMarker();

  @override
  void accept(LineVisitor visitor) {
    visitor.visitSourceEndMarker(this);
  }
}