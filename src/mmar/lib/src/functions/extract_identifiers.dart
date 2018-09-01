import '../ast/ast.dart';
import '../mmar_error.dart';
import '../token.dart';

/// Extracts all identifiers from the given MMAR AST [lines].
/// 
/// Since the result is a set of all identifiers, this function
/// also returns a list of errors representing identifiers that
/// were defined more than once.
IdentifierExtractionResult extractIdentifiers(List<Line> lines) {
  final identifiers = new Identifiers();
  final List<MmarError> errors = [];

  final visitor = new _LineVisitor(identifiers);

  for (final Line line in lines) {
    try {
      line.accept(visitor);
    } on _IdentifierExtractionException catch (ex) {
      errors.add(MmarError(ex.token.sourceSpan, ex.message));
    }
  }

  return IdentifierExtractionResult(identifiers, errors);
}

class Identifiers {
  final Set<String> allIdentifiers = new Set();
  final Set<String> constants = new Set();
  final Set<String> labels = new Set();
}

class IdentifierExtractionResult {
  final Identifiers identifiers;
  final List<MmarError> errors;

  IdentifierExtractionResult(this.identifiers, this.errors);
}

class _IdentifierExtractionException implements Exception {
  final Token token;
  final String message;

  _IdentifierExtractionException(this.token, this.message);
}

class _LineVisitor implements LineVisitor {
  final Identifiers _identifiers;

  _LineVisitor(this._identifiers)
    : assert(_identifiers != null);

  @override
  void visitComment(Comment comment) { }

  @override
  void visitConstant(Constant constant) {
    final String identifier = constant.identifier.lexeme;

    _checkAlreadyDefined(constant.identifier, identifier);

    _identifiers.allIdentifiers.add(identifier);
    _identifiers.constants.add(identifier);
  }

  @override
  void visitDwDirective(DwDirective dwDirective) {
    if (dwDirective.label != null) {
      _visitLabel(dwDirective.label);
    }
  }

  @override
  void visitInstruction(Instruction instruction) {
    if (instruction.label != null) {
      _visitLabel(instruction.label);
    }
  }

  @override
  void visitLabelLine(LabelLine labelLine) {
    if (labelLine.label != null) {
      _visitLabel(labelLine.label);
    }
  }

  @override
  void visitOrgDirective(OrgDirective orgDirective) { }

  @override
  void visitSection(Section section) { }

  void _visitLabel(Label label) {
    final String identifier = label.identifier.lexeme;

    _checkAlreadyDefined(label.identifier, identifier);

    _identifiers.allIdentifiers.add(identifier);
    _identifiers.labels.add(identifier);
  }

  void _checkAlreadyDefined(Token token, String identifier) {
    if (_identifiers.allIdentifiers.contains(identifier)) {
      _error(token, 'Cannot redefine an identifier.');
    }
  }

  void _error(Token token, String message) {
    throw _IdentifierExtractionException(token, message);
  }
}