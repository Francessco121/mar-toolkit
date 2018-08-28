import 'package:meta/meta.dart';

import '../scanning/token.dart';
import '../scanning/token_type.dart';
import '../parsing/ast/ast.dart' as ast;
import '../writing/ir/ir.dart' as ir;
import '../assemble_error.dart';

class AstLineCompileResult {
  final List<ir.Line> lines;
  final List<AssembleError> errors;

  AstLineCompileResult({
    @required this.lines,
    @required this.errors
  })
    : assert(lines != null),
      assert(errors != null);
}

/// Compiles AST lines into a MAR IR.
class AstLineCompiler {
  AstLineCompileResult compile(List<ast.Line> astLines) {
    final List<ir.Line> irLines = [];
    final List<AssembleError> errors = [];

    // Compile the AST lines
    final state = new _AstCompilerState();
    final visitorResult = _AstLineVisitorResult();
    final nodeVisitor = new _AstLineVisitor(state, visitorResult);

    for (ast.Line astLine in astLines) {
      try {
        astLine.accept(nodeVisitor);
      } on _CompileException catch (ex) {
        errors.add(AssembleError(ex.token.sourceSpan, ex.message));
      }
    }

    // Merge sections, directives, and constants in a MAR friendly order

    // The ORG directive comes first (if it was defined)
    // (MAR does not support ORG values referencing constants so we can put it first)
    if (visitorResult.orgDirective != null) {
      irLines.add(visitorResult.orgDirective);
    }

    // Constants come before instructions and non-org directives 
    // (MAR does not allow constants to be referenced unless they are declared above)
    irLines.addAll(visitorResult.constants);

    // Then each section in the order they appeared
    visitorResult.sections.forEach((String sectionName, List<ir.Line> lines) {
      irLines.add(ir.Section(sectionName));
      irLines.addAll(lines);
    });

    // All set
    return AstLineCompileResult(
      lines: irLines,
      errors: errors
    );
  }
}

class _AstCompilerState {
  final Map<String, int> constants = {};
  final Set<String> labels = new Set();
}

class _AstLineVisitorResult {
  ir.OrgDirective orgDirective;

  final List<ir.Constant> constants = [];
  final Map<String, List<ir.Line>> sections = {};
}

class _CompileException implements Exception {
  final String message;
  final Token token;

  _CompileException(this.token, this.message);
}

class _AstLineVisitor implements ast.LineVisitor {
  String _currentSection;
  List<ir.Line> _currentSectionLines;

  final _AstConstExpressionVisitor _expressionVisitor;
  final _AstCompilerState _state;
  final _AstLineVisitorResult _result;

  _AstLineVisitor(this._state, this._result)
    : assert(_state != null),
      assert(_result != null),
      _expressionVisitor = new _AstConstExpressionVisitor(_state) {
    
    // Default to the text section
    _switchSection('text');
  }

  @override
  void visitComment(ast.Comment comment) {
    _addLine(ir.Comment(comment.comment.literal as String));
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
    _result.constants.add(ir.Constant(identifier, value,
      comment: constant.comment?.literal as String
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
          _evaluateExpression(astOperand.value as ast.ConstExpression),
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

    _addLine(ir.DwDirective(operands,
      label: dwDirective.label?.identifier?.lexeme,
      comment: dwDirective.comment?.literal as String
    ));
  }

  @override
  void visitInstruction(ast.Instruction instruction) {
    final ir.Mnemonic mnemonic = ir.stringToMnemonic(instruction.mnemonic.lexeme);

    if (mnemonic == null) {
      throw new _CompileException(instruction.mnemonic, 'Unknown mnemonic.');
    }

    ir.InstructionOperand operand1;
    ir.InstructionOperand operand2;

    if (instruction.operand1 != null) {
      operand1 = _convertInstructionOperand(instruction.operand1);

      if (operand1 == null) {
        throw new _CompileException(instruction.mnemonic, 'Invalid type for operand 1.');
      }

      if (instruction.operand2 != null) {
        operand2 = _convertInstructionOperand(instruction.operand2);

        if (operand2 == null) {
          throw new _CompileException(instruction.mnemonic, 'Invalid type for operand 2.');
        }
      }
    }

    _validateInstruction(mnemonic, 
      mnemonicToken: instruction.mnemonic,
      operand1: operand1, 
      operand2: operand2,
      operand1Token: instruction.mnemonic,
      operand2Token: instruction.mnemonic
    );

    _addLine(ir.Instruction(mnemonic,
      operand1: operand1,
      operand2: operand2,
      label: instruction.label?.identifier?.lexeme,
      comment: instruction.comment?.literal as String
    ));
  }

  @override
  void visitLabelLine(ast.LabelLine labelLine) {
    final String identifier = labelLine.label.identifier.lexeme;

    // Don't allow users to redefine labels
    if (_state.labels.contains(identifier)) {
      throw new _CompileException(labelLine.label.identifier, 'Cannot redefine label.');
    }

    _state.labels.add(identifier);

    _addLine(ir.Label(labelLine.label.identifier.lexeme, 
      comment: labelLine.comment?.literal as String
    ));
  }

  @override
  void visitOrgDirective(ast.OrgDirective orgDirective) {
    if (_result.orgDirective == null) {
      final int value = _evaluateExpression(orgDirective.expression);

      _result.orgDirective = ir.OrgDirective(value,
        comment: orgDirective.comment?.literal as String
      );
    } else {
      throw _CompileException(orgDirective.orgKeyword, "The 'org' directive cannot appear more than once.");
    }
  }

  @override
  void visitSection(ast.Section section) {
    _switchSection(section.identifier.lexeme);

    final String comment = section.comment?.literal as String;
    if (comment != null) {
      _addLine(ir.Comment(comment));
    }
  }

  ir.InstructionOperand _convertInstructionOperand(ast.InstructionOperand operand) {
    if (operand is ast.InstructionExpressionOperand) {
      final ast.InstructionExpressionOperand expressionOp = operand;
      
      if (expressionOp.expression is ast.IntegerExpression) {
        // Immediate operand
        final ast.IntegerExpression integerExpression = expressionOp.expression;

        return ir.ImmediateOperand(integerExpression.value);
      } else if (expressionOp.expression is ast.IdentifierExpression) {
        final ast.IdentifierExpression identifierExpression = expressionOp.expression;
        final String identifier = identifierExpression.identifier.lexeme;

        // Register, label, or constant
        final ir.Register register = ir.stringToRegister(identifier);

        if (register != null) {
          // Register
          return ir.RegisterOperand(register);
        } else if (_state.constants.containsKey(identifier)) {
          // Constant reference
          return ir.ConstOperand(identifier);
        } else if (_state.labels.contains(identifier)) {
          // Label
          return ir.LabelOperand(identifier);
        }

        throw new _CompileException(identifierExpression.identifier, 'Unknown identifier.');
      }
    } else if (operand is ast.MemoryReference) {
      final ast.MemoryReference memoryReference = operand;

      // Convert the memory operand
      final ir.MemoryOperand memoryOperand = _convertMemoryOperand(memoryReference.value);

      // Convert the displacement
      ir.Displacement displacement;
      if (memoryReference.displacementValue != null) {
        // Check if a displacement can even exist
        if (memoryOperand is! ir.RegisterOperand) {
          throw new _CompileException(memoryReference.displacementOperator, 
            'Memory displacements are only allowed if the left value is a register.'
          );
        }

        final ir.DisplacementOperand operand =
          _convertDisplacementOperand(memoryReference.displacementValue);

        final ir.DisplacementOperator $operator = 
          _convertDisplacementOperator(memoryReference.displacementOperator);

        displacement = ir.Displacement($operator, operand);
      }

      return ir.MemoryInstructionOperand(memoryOperand, 
        displacement: displacement
      );
    }

    return null;
  }

  ir.MemoryOperand _convertMemoryOperand(ast.MemoryValue operand) {
    if (operand is ast.IdentifierExpression) {
      // Label, constant, or register
      final ast.IdentifierExpression identifierExpression = operand;
      final String identifier = identifierExpression.identifier.lexeme;

      if (_state.labels.contains(identifier)) {
        // Label value
        return ir.LabelOperand(identifier);
      } else if (_state.constants.containsKey(identifier)) {
        // Constant reference
        return ir.ConstOperand(identifier);
      } else {
        final ir.Register register = ir.stringToRegister(identifier);

        if (register != null) {
          // Register value
          return ir.RegisterOperand(register);
        } else {
          throw new _CompileException(identifierExpression.identifier, 
            'Unknown identifier.'
          );
        }
      }
    } else if (operand is ast.IntegerExpression) {
      // Integer
      final ast.IntegerExpression integerExpression = operand;

      return ir.ImmediateOperand(integerExpression.value);
    }

    throw new ArgumentError.value(operand, 'operand');
  }

  ir.DisplacementOperand _convertDisplacementOperand(ast.MemoryValue operand) {
    if (operand is ast.IdentifierExpression) {
      // Label, constant, or register
      final ast.IdentifierExpression identifierExpression = operand;
      final String identifier = identifierExpression.identifier.lexeme;

      if (_state.labels.contains(identifier)) {
        // Label value
        return ir.LabelOperand(identifier);
      } else if (_state.constants.containsKey(identifier)) {
        // Constant reference
        return ir.ConstOperand(identifier);
      } else if (ir.stringToRegister(identifier) != null) {
        // Register value
        throw new _CompileException(identifierExpression.identifier, 'Displacement operand cannot be a register.');
      }
    } else if (operand is ast.IntegerExpression) {
      // Integer
      final ast.IntegerExpression integerExpression = operand;

      return ir.ImmediateOperand(integerExpression.value);
    }

    throw new ArgumentError.value(operand, 'operand');
  }

  ir.DisplacementOperator _convertDisplacementOperator(Token operatorToken) {
    if (operatorToken.type == TokenType.plus) {
      return ir.DisplacementOperator.plus;
    } else if (operatorToken.type == TokenType.minus) {
      return ir.DisplacementOperator.minus;
    } else {
      throw new _CompileException(operatorToken, 
        "Invalid displacement operator. Must be either '+' or '-'."
      );
    }
  }

  void _validateInstruction(ir.Mnemonic mnemonic, {
    Token mnemonicToken,
    ir.InstructionOperand operand1, 
    ir.InstructionOperand operand2,
    Token operand1Token,
    Token operand2Token
  }) {
    // Get the instruction definition
    final ir.InstructionDefinition instructionDef = ir.mnemonicsToInstructionDefs[mnemonic];

    if (instructionDef == null) {
      throw new ArgumentError.value(mnemonic, 'mnemonic',
        '$mnemonic has no corresponding instruction definition!'
      );
    }

    // Get type flags for each operand
    final int op1Flag = ir.operandToTypeFlag(operand1);
    final int op2Flag = ir.operandToTypeFlag(operand2);

    // Validate operand 1
    if (!instructionDef.operand1.isFlagValid(op1Flag)) {
      throw new _CompileException(operand1Token, 
        'Operand 1 of ${ir.mnemonicToString(mnemonic)} cannot be ${ir.operandTypeFlagToString(op1Flag)}. '
        'Valid types are: ${instructionDef.operand1.createHumanReadableTypeList()}.'
      );
    }

    // Validate operand 2
    if (!instructionDef.operand2.isFlagValid(op2Flag)) {
      throw new _CompileException(operand2Token, 
        'Operand 2 of ${ir.mnemonicToString(mnemonic)} cannot be ${ir.operandTypeFlagToString(op2Flag)}. '
        'Valid types are: ${instructionDef.operand2.createHumanReadableTypeList()}.'
      );
    }
  }

  int _evaluateExpression(ast.ConstExpression expression) {
    return expression.accept(_expressionVisitor);
  }

  void _addLine(ir.Line line) {
    _currentSectionLines.add(line);
  }

  void _switchSection(String section) {
    if (section == _currentSection) {
      return;
    }

    List<ir.Line> newSectionLines = _result.sections[section];

    if (newSectionLines == null) {
      newSectionLines = [];
      _result.sections[section] = newSectionLines;
    }

    _currentSection = section;
    _currentSectionLines = newSectionLines;
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

    if (expression.$operator.type == TokenType.plus) {
      return leftValue + rightValue;
    } else if (expression.$operator.type == TokenType.minus) {
      return leftValue - rightValue;
    } else {
      throw new _CompileException(expression.$operator, 'Invalid binary operator.');
    }
  }

  @override
  int visitConstGroupExpression(ast.ConstGroupExpression expression) {
    return _evaluate(expression.expression);
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