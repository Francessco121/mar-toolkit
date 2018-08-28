import 'package:meta/meta.dart';

import 'line.dart';
import 'line_visitor.dart';

@immutable
class Section implements Line {
  @override
  final String comment;
  
  final String identifier;

  const Section(this.identifier, {this.comment});

  @override
  void accept(LineVisitor visitor) {
    visitor.visitSection(this);
  }
}