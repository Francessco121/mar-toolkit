import 'disassembled_comment.dart';
import 'disassembled_dw_directive.dart';
import 'disassembled_instruction.dart';
import 'disassembled_label.dart';

abstract class DisassembledContentVisitor {
  void visitComment(DisassembledComment comment);
  void visitDwDirective(DisassembledDwDirective directive);
  void visitInstruction(DisassembledInstruction instruction);
  void visitLabel(DisassembledLabel label);
}