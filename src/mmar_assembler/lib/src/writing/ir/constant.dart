import 'package:meta/meta.dart';

import 'line.dart';
import 'line_visitor.dart';

@immutable
class Constant implements Line {
  @override
  final String comment;
  
  final String identifier;
  final int value;

  const Constant(this.identifier, this.value, {this.comment});

  @override
  void accept(LineVisitor visitor) {
    visitor.visitConstant(this);
  }
}