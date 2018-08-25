import 'package:meta/meta.dart';

import '../../scanning/token.dart';
import 'label.dart';
import 'line.dart';
import 'line_visitor.dart';

@immutable
class LabelLine implements Line {
  final Token comment;
  final Label label;

  const LabelLine({
    @required this.label,
    @required this.comment
  })
    : assert(label != null);

  @override
  void accept(LineVisitor visitor) {
    visitor.visitLabelLine(this);
  }
}