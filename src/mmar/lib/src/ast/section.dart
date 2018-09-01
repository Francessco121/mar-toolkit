import 'package:meta/meta.dart';

import '../token.dart';
import 'line.dart';
import 'line_visitor.dart';

@immutable
class Section implements Line {
  @override
  final Token comment;
  
  final Token dotToken;
  final Token identifier;

  const Section({
    @required this.dotToken,
    @required this.identifier,
    @required this.comment
  })
    : assert(dotToken != null),
      assert(identifier != null);

  @override
  void accept(LineVisitor visitor) {
    visitor.visitSection(this);
  }
}