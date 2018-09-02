import 'disassembled_content.dart';
import 'disassembled_content_visitor.dart';

class DisassembledComment implements DisassembledContent {
  final String comment;

  DisassembledComment(this.comment);

  @override
  void accept(DisassembledContentVisitor visitor) {
    visitor.visitComment(this);
  }
}