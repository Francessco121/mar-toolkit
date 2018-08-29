import 'package:meta/meta.dart';

import '../scanning/token.dart';
import '../scanning/token_type.dart';
import '../parsing/ast/ast.dart' as ast;
import '../writing/ir/ir.dart' as ir;
import '../assemble_error.dart';
import 'identifier_extractor.dart';

/// Compiles AST lines into a MAR IR.
AstLineCompileResult compileAstLines(List<ast.Line> astLines, Identifiers identifiers) {
  final List<ir.Line> irLines = [];
  final List<AssembleError> errors = [];

  // Compile the AST lines
  final nodeVisitor = new _AstLineVisitor(identifiers);

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
  if (nodeVisitor.orgDirective != null) {
    irLines.add(nodeVisitor.orgDirective);
  }

  // Constants come before instructions and non-org directives 
  // (MAR does not allow constants to be referenced unless they are declared above)
  irLines.addAll(nodeVisitor.constants);

  // Then each section in the order they appeared
  nodeVisitor.sections.forEach((String sectionName, List<ir.Line> lines) {
    irLines.add(ir.Section(sectionName));
    irLines.addAll(lines);
  });

  // All set
  return AstLineCompileResult(
    lines: irLines,
    errors: errors
  );
}

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

class _CompileException implements Exception {
  final String message;
  final Token token;

  _CompileException(this.token, this.message);
}

class _AstLineVisitor implements ast.LineVisitor, ast.ConstExpressionVisitor {
  /// The ORG directive or `null` if none were visited.
  ir.OrgDirective get orgDirective => _orgDirective;

  /// All constants that were visited.
  final List<ir.Constant> constants = [];

  /// All non-constants and non-org-directives that were visited,
  /// grouped by the section they were defined under.
  final Map<String, List<ir.Line>> sections = {};

  ir.OrgDirective _orgDirective;
  String _currentSection;
  List<ir.Line> _currentSectionLines;

  final Map<String, int> _compiledConstants = {};

  final Identifiers _identifiers;

  _AstLineVisitor(this._identifiers)
    : assert(_identifiers != null) {

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

    // Compile the constant's value
    final int value = _evaluate(constant.expression);

    // Store the compiled value so others can reference it
    _compiledConstants[identifier] = value;
    
    // Add the constant line
    constants.add(ir.Constant(identifier, value,
      comment: _extractComment(constant)
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
          _evaluate(astOperand.value as ast.ConstExpression),
          duplicate: astOperand.duplicate == null
            ? null
            : _evaluate(astOperand.duplicate)
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
      comment: _extractComment(dwDirective)
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
      comment: _extractComment(instruction)
    ));
  }

  @override
  void visitLabelLine(ast.LabelLine labelLine) {
    final String identifier = labelLine.label.identifier.lexeme;

    _addLine(ir.Label(identifier, 
      comment: _extractComment(labelLine)
    ));
  }

  @override
  void visitOrgDirective(ast.OrgDirective orgDirective) {
    if (_orgDirective == null) {
      final int value = _evaluate(orgDirective.expression);

      _orgDirective = ir.OrgDirective(value,
        comment: _extractComment(orgDirective)
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

  @override
  int visitConstBinaryExpression(ast.ConstBinaryExpression expression) {
    int leftValue = _evaluate(expression.left);
    int rightValue = _evaluate(expression.right);

    if (expression.$operator.type == TokenType.plus) {
      return leftValue + rightValue;
    } else if (expression.$operator.type == TokenType.minus) {
      return leftValue - rightValue;
    } else if (expression.$operator.type == TokenType.forwardSlash) {
      return (leftValue / rightValue).floor();
    } else if (expression.$operator.type == TokenType.star) {
      return leftValue * rightValue;
    } else if (expression.$operator.type == TokenType.percent) {
      return leftValue % rightValue;
    } else {
      throw new _CompileException(expression.$operator, 'Invalid binary operator.');
    }
  }

  @override
  int visitConstGroupExpression(ast.ConstGroupExpression expression) {
    return _evaluate(expression.expression);
  }

  @override
  int visitConstUnaryExpression(ast.ConstUnaryExpression unary) {
    int value = _evaluate(unary.expression);

    if (unary.$operator.type == TokenType.minus) {
      return -value;
    } else {
      throw new _CompileException(unary.$operator, 'Invalid unary operator.');
    }
  }

  @override
  int visitIdentifierExpression(ast.IdentifierExpression identifierExpression) {
    int value = _compiledConstants[identifierExpression.identifier.lexeme];

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
        } else if (_identifiers.constants.contains(identifier)) {
          // Constant reference
          return ir.ConstOperand(identifier);
        } else if (_identifiers.labels.contains(identifier)) {
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

      if (_identifiers.labels.contains(identifier)) {
        // Label value
        return ir.LabelOperand(identifier);
      } else if (_identifiers.constants.contains(identifier)) {
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

      if (_identifiers.labels.contains(identifier)) {
        // Label value
        return ir.LabelOperand(identifier);
      } else if (_identifiers.constants.contains(identifier)) {
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

  String _extractComment(ast.Line line) {
    return line.comment?.literal as String;
  }

  int _evaluate(ast.ConstExpression expression) {
    return expression.accept(this);
  }

  void _addLine(ir.Line line) {
    _currentSectionLines.add(line);
  }

  void _switchSection(String section) {
    if (section == _currentSection) {
      return;
    }

    List<ir.Line> newSectionLines = sections[section];

    if (newSectionLines == null) {
      newSectionLines = [];
      sections[section] = newSectionLines;
    }

    _currentSection = section;
    _currentSectionLines = newSectionLines;
  }
}