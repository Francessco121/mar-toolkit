import 'statement.dart';
import 'statement_visitor.dart';

class Entry implements Statement {
  final List<Statement> body;

  Entry(this.body) {
    if (body == null) throw ArgumentError.notNull('body');
  }

  @override
  void accept(StatementVisitor visitor) {
    visitor.visitEntry(this);
  }
}