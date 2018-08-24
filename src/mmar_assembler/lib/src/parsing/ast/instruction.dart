import 'package:meta/meta.dart';

import '../../scanning/token.dart';
import 'expression.dart';
import 'label.dart';
import 'node.dart';
import 'node_visitor.dart';

@immutable
class Instruction implements Node {
  final Label label;
  final Token mnemonic;
  final Expression operand1;
  final Token commaToken;
  final Expression operand2;

  const Instruction({
    @required this.label,
    @required this.mnemonic,
    @required this.operand1,
    @required this.commaToken,
    @required this.operand2
  })
    : assert(mnemonic != null);

  @override
  void accept(NodeVisitor visitor) {
    visitor.visitInstruction(this);
  }
}