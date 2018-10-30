import 'dart:collection';

import 'package:mar/mar.dart';

import '../ast/ast.dart';
import '../hlml_problem.dart';

CompileResult compile(List<Statement> statements) {
  final visitor = new _StatementVisitor();

  for (final Statement statement in statements) {
    statement.accept(visitor);
  }

  return CompileResult(
    UnmodifiableListView(visitor.lines),
    visitor.problems.build()
  );
}

class CompileResult {
  final UnmodifiableListView<Line> lines;
  final HlmlProblems problems;

  CompileResult(this.lines, this.problems) {
    if (lines == null) throw ArgumentError.notNull('lines');
    if (problems == null) throw ArgumentError.notNull('problems');
  }
}

class _StatementVisitor implements StatementVisitor {
  final List<Line> lines = [];
  final problems = new HlmlProblemsBuilder();

  @override
  void visitEntry(Entry entry) {
    _add(Section('text', comment: 'entry start'));

    for (final Statement statement in entry.body) {
      statement.accept(this);
    }

    _add(Instruction(Mnemonic.brk, comment: 'entry end'));
  }

  @override
  void visitExpressionStatement(ExpressionStatement expressionStatement) {
    // TODO: implement visitExpressionStatement
  }

  @override
  void visitVariableDeclaration(VariableDeclaration variableDeclaration) {
    // TODO: implement visitVariableDeclaration
  }

  void _add(Line line) {
    lines.add(line);
  }
}
