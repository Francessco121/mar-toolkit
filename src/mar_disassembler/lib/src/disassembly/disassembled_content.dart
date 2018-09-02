import 'disassembled_content_visitor.dart';

abstract class DisassembledContent {
  void accept(DisassembledContentVisitor visitor);
}