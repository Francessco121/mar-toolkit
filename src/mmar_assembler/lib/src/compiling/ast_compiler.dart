import '../scanning/token.dart';
import '../scanning/token_type.dart';
import '../parsing/ast/ast.dart' as ast;
import '../writing/ir/ir.dart' as ir;
import 'ast_compile_error.dart';
import 'ast_compile_result.dart';

/// Compiles a Macro MAR AST into a MAR IR.
class AstCompiler {
  AstCompileResult compile(List<ast.Line> astLines) {
    final List<ir.Line> irLines = [];
    final List<AstCompileError> errors = [];

    final state = new _AstCompilerState();
    final nodeVisitor = new _AstLineVisitor(state, irLines);

    for (ast.Line astLine in astLines) {
      try {
        astLine.accept(nodeVisitor);
      } on _CompileException catch (ex) {
        errors.add(AstCompileError(
          message: ex.message,
          token: ex.token
        ));
      }
    }

    return AstCompileResult(
      lines: irLines,
      errors: errors
    );
  }
}

class _AstCompilerState {
  final Map<String, int> constants = {};
}

class _CompileException implements Exception {
  final String message;
  final Token token;

  _CompileException(this.token, this.message);
}

class _AstLineVisitor implements ast.LineVisitor {
  final _AstConstExpressionVisitor _expressionVisitor;
  final _AstCompilerState _state;
  final List<ir.Line> _lines;

  _AstLineVisitor(this._state, this._lines)
    : assert(_state != null),
      assert(_lines != null),
      _expressionVisitor = new _AstConstExpressionVisitor(_state);

  @override
  void visitComment(ast.Comment comment) {
    _lines.add(ir.Comment(comment.comment.literal));
  }

  @override
  void visitConstant(ast.Constant constant) {
    final String identifier = constant.identifier.lexeme;

    // Don't allow users to redefine constants
    if (_state.constants.containsKey(identifier)) {
      throw new _CompileException(constant.identifier, 'Cannot redefine a constant.');
    }

    // Compile the constant's value
    final int value = _evaluateExpression(constant.expression);

    // Store the compiled value so others can reference it
    _state.constants[identifier] = value;
    
    // Add the constant line
    _lines.add(ir.Constant(identifier, value,
      comment: constant.comment?.literal
    ));
  }

  @override
  void visitDwDirective(ast.DwDirective dwDirective) {
    final List<ir.DwOperand> operands = [];

    int operandNumber = 1;
    for (ast.DwOperand astOperand in dwDirective.operands) {
      if (astOperand.value is ast.StringLiteral) {
        final ast.StringLiteral stringLiteral = astOperand.value;
        operands.add(ir.DwOperand(stringLiteral.value));
      } else if (astOperand.value is ast.ConstExpression) {
        operands.add(ir.DwOperand(
          _evaluateExpression(astOperand.value),
          duplicate: astOperand.duplicate == null
            ? null
            : _evaluateExpression(astOperand.duplicate)
        ));
      } else {
        throw new _CompileException(dwDirective.dwToken, 
          'Operand #$operandNumber is not a valid DW operand.'
        );
      }

      operandNumber++;
    }

    _lines.add(ir.DwDirective(operands,
      label: dwDirective.label?.identifier?.lexeme,
      comment: dwDirective.comment?.literal
    ));
  }

  @override
  void visitInstruction(ast.Instruction instruction) {
    // TODO: implement visitInstruction
  }

  @override
  void visitLabelLine(ast.LabelLine labelLine) {
    _lines.add(ir.Label(labelLine.label.identifier.lexeme, 
      comment: labelLine.comment?.literal
    ));
  }

  @override
  void visitOrgDirective(ast.OrgDirective orgDirective) {
    final int value = _evaluateExpression(orgDirective.expression);

    _lines.add(ir.OrgDirective(value,
      comment: orgDirective.comment?.literal
    ));
  }

  @override
  void visitSection(ast.Section section) {
    _lines.add(ir.Section(section.identifier.lexeme,
      comment: section.comment?.literal
    ));
  }

  int _evaluateExpression(ast.ConstExpression expression) {
    return expression.accept(_expressionVisitor);
  }
}

class _AstConstExpressionVisitor implements ast.ConstExpressionVisitor {
  final _AstCompilerState _state;

  _AstConstExpressionVisitor(this._state)
    : assert(_state != null);

  @override
  int visitConstBinaryExpression(ast.ConstBinaryExpression expression) {
    int leftValue = _evaluate(expression.left);
    int rightValue = _evaluate(expression.right);

    if (expression.operator_.type == TokenType.plus) {
      return leftValue + rightValue;
    } else if (expression.operator_.type == TokenType.minus) {
      return leftValue - rightValue;
    } else {
      throw new _CompileException(expression.operator_, 'Invalid binary operator.');
    }
  }

  @override
  int visitIdentifierExpression(ast.IdentifierExpression identifierExpression) {
    int value = _state.constants[identifierExpression.identifier.lexeme];

    if (value != null) {
      return value;
    } else {
      throw new _CompileException(identifierExpression.identifier, 'Unknown constant identifier.');
    }
  }

  @override
  int visitIntegerExpression(ast.IntegerExpression integerExpression) {
    return integerExpression.value;
  }

  int _evaluate(ast.ConstExpression expression) {
    return expression.accept(this);
  }
}