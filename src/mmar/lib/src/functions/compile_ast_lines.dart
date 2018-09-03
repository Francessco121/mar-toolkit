import 'dart:collection';

import 'package:mar/mar.dart' as mar;
import 'package:meta/meta.dart';

import '../ast/ast.dart';
import '../mmar_error.dart';
import '../token.dart';
import '../token_type.dart';
import 'extract_identifiers.dart'
  show Identifiers;

/// Compiles a list of MMAR AST [lines] into a MAR IR.
/// 
/// This function requires a set of [identifiers] that have already
/// been extracted from the [lines].
AstLineCompileResult compileAstLines(List<Line> lines, Identifiers identifiers) {
  assert(lines != null);
  assert(identifiers != null);
  
  final List<mar.Line> marCode = [];
  final List<MmarError> errors = [];

  // Compile the AST lines
  final nodeVisitor = new _AstLineVisitor(identifiers);

  for (Line astLine in lines) {
    try {
      astLine.accept(nodeVisitor);
    } on _CompileException catch (ex) {
      errors.add(MmarError(ex.token.sourceSpan, ex.message));
    }
  }

  // Merge sections, directives, and constants in a MAR friendly order

  // The ORG directive comes first (if it was defined)
  // (MAR does not support ORG values referencing constants so we can put it first)
  if (nodeVisitor.orgDirective != null) {
    marCode.add(nodeVisitor.orgDirective);
  }

  // Constants come before instructions and non-org directives 
  // (MAR does not allow constants to be referenced unless they are declared above)
  marCode.addAll(nodeVisitor.constants);

  // Then each section in the order they appeared
  nodeVisitor.sections.forEach((String sectionName, List<mar.Line> marLines) {
    marCode.add(mar.Section(sectionName));
    marCode.addAll(marLines);
  });

  // All set
  return AstLineCompileResult(
    marLines: UnmodifiableListView(marCode),
    errors: UnmodifiableListView(errors)
  );
}

class AstLineCompileResult {
  final UnmodifiableListView<mar.Line> marLines;
  final UnmodifiableListView<MmarError> errors;

  AstLineCompileResult({
    @required this.marLines,
    @required this.errors
  })
    : assert(marLines != null),
      assert(errors != null);
}

class _CompileException implements Exception {
  final String message;
  final Token token;

  _CompileException(this.token, this.message);
}

class _AstLineVisitor implements LineVisitor, ConstExpressionVisitor {
  /// The ORG directive or `null` if none were visited.
  mar.OrgDirective get orgDirective => _orgDirective;

  /// All constants that were visited.
  final List<mar.Constant> constants = [];

  /// All non-constants and non-org-directives that were visited,
  /// grouped by the section they were defined under.
  final Map<String, List<mar.Line>> sections = {};

  mar.OrgDirective _orgDirective;
  String _currentSection;
  List<mar.Line> _currentSectionLines;

  final Map<String, int> _compiledConstants = {};
  
  /// A stack representing the last section being read per source
  final _sectionStack = new ListQueue<String>();

  final Identifiers _identifiers;

  _AstLineVisitor(this._identifiers)
    : assert(_identifiers != null) {

    // Default to the text section
    _switchSection('text');
  }

  @override
  void visitComment(Comment comment) {
    _addLine(mar.Comment(comment.comment.literal as String));
  }

  @override
  void visitConstant(Constant constant) {
    final String identifier = constant.identifier.lexeme;

    // Compile the constant's value
    final int value = _evaluate(constant.expression);

    // Store the compiled value so others can reference it
    _compiledConstants[identifier] = value;
    
    // Add the constant line
    constants.add(mar.Constant(identifier, value,
      comment: _extractComment(constant)
    ));
  }

  @override
  void visitDwDirective(DwDirective dwDirective) {
    final List<mar.DwOperand> operands = [];

    int operandNumber = 1;
    for (DwOperand astOperand in dwDirective.operands) {
      if (astOperand.value is StringLiteral) {
        final StringLiteral stringLiteral = astOperand.value;
        operands.add(mar.DwOperand(stringLiteral.value));
      } else if (astOperand.value is ConstExpression) {
        operands.add(mar.DwOperand(
          _evaluate(astOperand.value as ConstExpression),
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

    _addLine(mar.DwDirective(operands,
      label: dwDirective.label?.identifier?.lexeme,
      comment: _extractComment(dwDirective)
    ));
  }

  @override
  void visitInstruction(Instruction instruction) {
    final mar.Mnemonic mnemonic = mar.stringToMnemonic(instruction.mnemonic.lexeme);

    if (mnemonic == null) {
      throw new _CompileException(instruction.mnemonic, 'Unknown mnemonic.');
    }

    mar.InstructionOperand operand1;
    mar.InstructionOperand operand2;

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

    _addLine(mar.Instruction(mnemonic,
      operand1: operand1,
      operand2: operand2,
      label: instruction.label?.identifier?.lexeme,
      comment: _extractComment(instruction)
    ));
  }

  @override
  void visitLabelLine(LabelLine labelLine) {
    final String identifier = labelLine.label.identifier.lexeme;

    _addLine(mar.Label(identifier, 
      comment: _extractComment(labelLine)
    ));
  }

  @override
  void visitOrgDirective(OrgDirective orgDirective) {
    if (_orgDirective == null) {
      final int value = _evaluate(orgDirective.expression);

      _orgDirective = mar.OrgDirective(value,
        comment: _extractComment(orgDirective)
      );
    } else {
      throw _CompileException(orgDirective.orgKeyword, "The 'org' directive cannot appear more than once.");
    }
  }

  @override
  void visitSection(Section section) {
    _switchSection(section.identifier.lexeme);

    final String comment = section.comment?.literal as String;
    if (comment != null) {
      _addLine(mar.Comment(comment));
    }
  }

  @override
  void visitSourceStartMarker(_) {
    // Push the current section
    _sectionStack.addFirst(_currentSection);

    // Switch to text
    _switchSection('text');
  }

  @override
  void visitSourceEndMarker(_) {
    // Pop the previous section
    final String section = _sectionStack.removeFirst();

    // Switch to the previous section
    _switchSection(section);
  }

  @override
  int visitConstBinaryExpression(ConstBinaryExpression expression) {
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
  int visitConstGroupExpression(ConstGroupExpression expression) {
    return _evaluate(expression.expression);
  }

  @override
  int visitConstUnaryExpression(ConstUnaryExpression unary) {
    int value = _evaluate(unary.expression);

    if (unary.$operator.type == TokenType.minus) {
      return -value;
    } else {
      throw new _CompileException(unary.$operator, 'Invalid unary operator.');
    }
  }

  @override
  int visitIdentifierExpression(IdentifierExpression identifierExpression) {
    int value = _compiledConstants[identifierExpression.identifier.lexeme];

    if (value != null) {
      return value;
    } else {
      throw new _CompileException(identifierExpression.identifier, 'Unknown constant identifier.');
    }
  }

  @override
  int visitIntegerExpression(IntegerExpression integerExpression) {
    return integerExpression.value;
  }

  mar.InstructionOperand _convertInstructionOperand(InstructionOperand operand) {
    if (operand is InstructionExpressionOperand) {
      final InstructionExpressionOperand expressionOp = operand;
      
      if (expressionOp.expression is IntegerExpression) {
        // Immediate operand
        final IntegerExpression integerExpression = expressionOp.expression;

        return mar.ImmediateOperand(integerExpression.value);
      } else if (expressionOp.expression is IdentifierExpression) {
        final IdentifierExpression identifierExpression = expressionOp.expression;
        final String identifier = identifierExpression.identifier.lexeme;

        // Register, label, or constant
        final mar.Register register = mar.stringToRegister(identifier);

        if (register != null) {
          // Register
          return mar.RegisterOperand(register);
        } else if (_identifiers.constants.contains(identifier)) {
          // Constant reference
          return mar.ConstOperand(identifier);
        } else if (_identifiers.labels.contains(identifier)) {
          // Label
          return mar.LabelOperand(identifier);
        }

        throw new _CompileException(identifierExpression.identifier, 'Unknown identifier.');
      }
    } else if (operand is MemoryReference) {
      final MemoryReference memoryReference = operand;

      // Convert the memory operand
      final mar.MemoryOperand memoryOperand = _convertMemoryOperand(memoryReference.value);

      // Convert the displacement
      mar.Displacement displacement;
      if (memoryReference.displacementValue != null) {
        // Check if a displacement can even exist
        if (memoryOperand is! mar.RegisterOperand) {
          throw new _CompileException(memoryReference.displacementOperator, 
            'Memory displacements are only allowed if the left value is a register.'
          );
        }

        final mar.DisplacementOperand operand =
          _convertDisplacementOperand(memoryReference.displacementValue);

        final mar.DisplacementOperator $operator = 
          _convertDisplacementOperator(memoryReference.displacementOperator);

        displacement = mar.Displacement($operator, operand);
      }

      return mar.MemoryInstructionOperand(memoryOperand, 
        displacement: displacement
      );
    }

    return null;
  }

  mar.MemoryOperand _convertMemoryOperand(MemoryValue operand) {
    if (operand is IdentifierExpression) {
      // Label, constant, or register
      final IdentifierExpression identifierExpression = operand;
      final String identifier = identifierExpression.identifier.lexeme;

      if (_identifiers.labels.contains(identifier)) {
        // Label value
        return mar.LabelOperand(identifier);
      } else if (_identifiers.constants.contains(identifier)) {
        // Constant reference
        return mar.ConstOperand(identifier);
      } else {
        final mar.Register register = mar.stringToRegister(identifier);

        if (register != null) {
          // Register value
          return mar.RegisterOperand(register);
        } else {
          throw new _CompileException(identifierExpression.identifier, 
            'Unknown identifier.'
          );
        }
      }
    } else if (operand is IntegerExpression) {
      // Integer
      final IntegerExpression integerExpression = operand;

      return mar.ImmediateOperand(integerExpression.value);
    }

    throw new ArgumentError.value(operand, 'operand');
  }

  mar.DisplacementOperand _convertDisplacementOperand(MemoryValue operand) {
    if (operand is IdentifierExpression) {
      // Label, constant, or register
      final IdentifierExpression identifierExpression = operand;
      final String identifier = identifierExpression.identifier.lexeme;

      if (_identifiers.labels.contains(identifier)) {
        // Label value
        return mar.LabelOperand(identifier);
      } else if (_identifiers.constants.contains(identifier)) {
        // Constant reference
        return mar.ConstOperand(identifier);
      } else if (mar.stringToRegister(identifier) != null) {
        // Register value
        throw new _CompileException(identifierExpression.identifier, 'Displacement operand cannot be a register.');
      }
    } else if (operand is IntegerExpression) {
      // Integer
      final IntegerExpression integerExpression = operand;

      return mar.ImmediateOperand(integerExpression.value);
    }

    throw new ArgumentError.value(operand, 'operand');
  }

  mar.DisplacementOperator _convertDisplacementOperator(Token operatorToken) {
    if (operatorToken.type == TokenType.plus) {
      return mar.DisplacementOperator.plus;
    } else if (operatorToken.type == TokenType.minus) {
      return mar.DisplacementOperator.minus;
    } else {
      throw new _CompileException(operatorToken, 
        "Invalid displacement operator. Must be either '+' or '-'."
      );
    }
  }

  void _validateInstruction(mar.Mnemonic mnemonic, {
    Token mnemonicToken,
    mar.InstructionOperand operand1, 
    mar.InstructionOperand operand2,
    Token operand1Token,
    Token operand2Token
  }) {
    // Get the instruction definition
    final mar.InstructionDefinition instructionDef = mar.mnemonicsToInstructionDefs[mnemonic];

    if (instructionDef == null) {
      throw new ArgumentError.value(mnemonic, 'mnemonic',
        '$mnemonic has no corresponding instruction definition!'
      );
    }

    // Get type flags for each operand
    final int op1Flag = mar.operandToTypeFlag(operand1);
    final int op2Flag = mar.operandToTypeFlag(operand2);

    // Validate operand 1
    if (!instructionDef.operand1.isFlagValid(op1Flag)) {
      throw new _CompileException(operand1Token, 
        'Operand 1 of ${mar.mnemonicToString(mnemonic)} cannot be ${mar.operandTypeFlagToString(op1Flag)}. '
        'Valid types are: ${instructionDef.operand1.createHumanReadableTypeList()}.'
      );
    }

    // Validate operand 2
    if (!instructionDef.operand2.isFlagValid(op2Flag)) {
      throw new _CompileException(operand2Token, 
        'Operand 2 of ${mar.mnemonicToString(mnemonic)} cannot be ${mar.operandTypeFlagToString(op2Flag)}. '
        'Valid types are: ${instructionDef.operand2.createHumanReadableTypeList()}.'
      );
    }
  }

  String _extractComment(Line line) {
    return line.comment?.literal as String;
  }

  int _evaluate(ConstExpression expression) {
    return expression.accept(this);
  }

  void _addLine(mar.Line line) {
    _currentSectionLines.add(line);
  }

  void _switchSection(String section) {
    if (section == _currentSection) {
      return;
    }

    List<mar.Line> newSectionLines = sections[section];

    if (newSectionLines == null) {
      newSectionLines = [];
      sections[section] = newSectionLines;
    }

    _currentSection = section;
    _currentSectionLines = newSectionLines;
  }
}