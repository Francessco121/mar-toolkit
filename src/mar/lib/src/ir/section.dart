import 'line.dart';
import 'line_visitor.dart';

class Section implements Line {
  @override
  final String comment;
  
  final String identifier;

  Section(this.identifier, {this.comment});

  @override
  void accept(LineVisitor visitor) {
    visitor.visitSection(this);
  }
}