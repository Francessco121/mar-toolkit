import '../parsing/ast/ast.dart' as ast;
import '../scanning/token.dart';
import '../assemble_error.dart';

/// Generates a list of identifiers from a list of AST lines.
/// 
/// This is done before compilation so that identifiers can be referenced
/// anywhere in the file and not requiring them to be defined before they are used.
IdentifierExtractionResult extractIdentifiers(List<ast.Line> fromLines) {
  final identifiers = new Identifiers();
  final List<AssembleError> errors = [];

  final visitor = new _LineVisitor(identifiers);

  for (final ast.Line line in fromLines) {
    try {
      line.accept(visitor);
    } on _IdentifierExtractionException catch (ex) {
      errors.add(AssembleError(ex.token.sourceSpan, ex.message));
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
  final List<AssembleError> errors;

  IdentifierExtractionResult(this.identifiers, this.errors);
}

class _IdentifierExtractionException implements Exception {
  final Token token;
  final String message;

  _IdentifierExtractionException(this.token, this.message);
}

class _LineVisitor implements ast.LineVisitor {
  final Identifiers _identifiers;

  _LineVisitor(this._identifiers)
    : assert(_identifiers != null);

  @override
  void visitComment(ast.Comment comment) { }

  @override
  void visitConstant(ast.Constant constant) {
    final String identifier = constant.identifier.lexeme;

    _checkAlreadyDefined(constant.identifier, identifier);

    _identifiers.allIdentifiers.add(identifier);
    _identifiers.constants.add(identifier);
  }

  @override
  void visitDwDirective(ast.DwDirective dwDirective) {
    if (dwDirective.label != null) {
      _visitLabel(dwDirective.label);
    }
  }

  @override
  void visitInstruction(ast.Instruction instruction) {
    if (instruction.label != null) {
      _visitLabel(instruction.label);
    }
  }

  @override
  void visitLabelLine(ast.LabelLine labelLine) {
    if (labelLine.label != null) {
      _visitLabel(labelLine.label);
    }
  }

  @override
  void visitOrgDirective(ast.OrgDirective orgDirective) { }

  @override
  void visitSection(ast.Section section) { }

  void _visitLabel(ast.Label label) {
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