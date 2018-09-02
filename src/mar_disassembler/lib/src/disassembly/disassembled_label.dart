import 'disassembled_content.dart';
import 'disassembled_content_visitor.dart';

class DisassembledLabel implements DisassembledContent {
  final String label;

  DisassembledLabel(this.label);

  @override
  void accept(DisassembledContentVisitor visitor) {
    visitor.visitLabel(this);
  }
}