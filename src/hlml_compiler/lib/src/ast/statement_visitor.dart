import 'entry.dart';
import 'expression_statement.dart';
import 'variable_declaration.dart';

abstract class StatementVisitor {
  void visitEntry(Entry entry);
  void visitExpressionStatement(ExpressionStatement expressionStatement);
  void visitVariableDeclaration(VariableDeclaration variableDeclaration);
}