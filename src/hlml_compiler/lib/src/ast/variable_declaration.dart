import 'package:meta/meta.dart';

import '../token.dart';
import 'expression.dart';
import 'statement.dart';
import 'statement_visitor.dart';
import 'variable_declaration_type.dart';

class VariableDeclaration implements Statement {
  final VariableDeclarationType type;
  final Token identifier;
  final Token typeIdentifier;
  final Expression initializer;

  VariableDeclaration({
    @required this.type,
    @required this.identifier,
    @required this.typeIdentifier,
    @required this.initializer
  }) {
    if (type == null) throw ArgumentError.notNull('type');
    if (identifier == null) throw ArgumentError.notNull('identifier');
    if (typeIdentifier == null) throw ArgumentError.notNull('typeIdentifier');
    if (initializer == null) throw ArgumentError.notNull('initializer');
  }

  @override
  void accept(StatementVisitor visitor) {
    visitor.visitVariableDeclaration(this);
  }
}