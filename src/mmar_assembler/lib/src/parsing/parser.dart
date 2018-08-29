import 'package:meta/meta.dart';

import '../scanning/token.dart';
import '../scanning/token_type.dart';
import '../assemble_error.dart';
import 'ast/ast.dart' as ast;

class _ParseException implements Exception { }

class ParseResult {
  final List<AssembleError> errors;
  final List<ast.Statement> statements;

  ParseResult({
    @required this.statements,
    @required this.errors
  })
    : assert(statements != null),
      assert(errors != null);
}

class Parser {
  int _current = 0;

  final List<AssembleError> _errors = [];

  final List<Token> _tokens;

  Parser(this._tokens)
    : assert(_tokens != null);

  ParseResult parse() {
    final List<ast.Statement> statements = [];

    // Parse until EOF
    while (!_isAtEnd()) {
      // Parse statement
      try {
        // Note: [statement] will be null if it was just a newline character
        final ast.Statement statement = _statement();

        if (statement != null) {
          statements.add(statement);
        }

        // Parse newline or EOF
        _consumeAny(const [TokenType.newline, TokenType.eof], 'Expected newline or end of file.');
      } on _ParseException {
        // Skip until newline or EOF
        while (true) {
          final Token token = _advance();

          if (token.type == TokenType.newline || token.type == TokenType.eof) {
            break;
          }
        }
      }
    }

    // Parse complete!
    return ParseResult(
      statements: statements,
      errors: _errors
    );
  }

  ast.Statement _statement() {
    if (_check(TokenType.once)) {
      // Once macro
      return _onceMacro(_advance());
    } else if (_check(TokenType.include)) {
      // Include macro
      return _includeMacro(_advance());
    } else {
      // Line
      return _line();
    }
  }

  ast.OnceMacro _onceMacro(Token onceKeyword) {
    return ast.OnceMacro(
      onceKeyword: onceKeyword,
      comment: _comment()
    );
  }

  ast.IncludeMacro _includeMacro(Token includeKeyword)  {
    // Read the file path string
    final Token filePathToken = _consume(TokenType.string, 'Expected include file path string.');

    return ast.IncludeMacro(
      includeKeyword: includeKeyword,
      filePathToken: filePathToken,
      comment: _comment()
    );
  }

  ast.Line _line() {
    if (_check(TokenType.dot)) {
      // Section
      return _section(_advance());
    } else if (_check(TokenType.org)) {
      // ORG directive
      return _orgDirective(_advance());
    } else if (_check(TokenType.dw)) {
      // Unlabeled DW directive
      return _dwDirective(null, _advance());
    } else if (_check(TokenType.identifier)) {
      // Constant or labelable
      final Token identifier = _advance();

      if (_check(TokenType.equ)) {
        // Parse constant
        return _constant(identifier, _advance());
      } else {
        // Parse labelable
        return _labelable(identifier);
      }
    } else if (_check(TokenType.comment)) {
      // Comment line
      return ast.Comment(comment: _comment());
    } else {
      return null;
    }
  }

  ast.Line _labelable(Token identifier) {
    // Parse the label if it exists
    ast.Label label;
    if (_check(TokenType.colon)) {
      label = new ast.Label(
        identifier: identifier,
        colonToken: _advance()
      );
    }

    if (label != null && _checkAny(const [TokenType.comment, TokenType.newline, TokenType.eof])) {
      // Label line
      return ast.LabelLine(
        label: label,
        comment: _comment()
      );
    } else {
      if (_check(TokenType.dw)) {
        // Labelable DW directive
        return _dwDirective(label, _advance()); 
      } else {
        // Instruction

        // Note: If we parsed a label, then the [identifier] is not the mnemonic,
        //       instead we need to parse it next.
        final Token mnemonic = label == null
          ? identifier
          : _consume(TokenType.identifier, 'Expected instruction mnemonic.');

        // Parse the instruction
        return _instruction(label, mnemonic);
      }
    }
  }

  ast.Section _section(Token dotToken) {
    final Token identifier = _consume(TokenType.identifier,
      'Expected section identifier.'
    );

    return ast.Section(
      dotToken: dotToken,
      identifier: identifier,
      comment: _comment()
    );
  }

  ast.Constant _constant(Token identifier, Token equToken) {
    final ast.ConstExpression expression = _constExpression();

    return ast.Constant(
      identifier: identifier,
      equToken: equToken,
      expression: expression,
      comment: _comment()
    );
  }

  ast.OrgDirective _orgDirective(Token orgToken) {
    final ast.ConstExpression expression = _constExpression();

    return ast.OrgDirective(
      orgKeyword: orgToken,
      expression: expression,
      comment: _comment()
    );
  }

  ast.DwDirective _dwDirective(ast.Label label, Token dwToken) {
    final List<ast.DwOperand> operands = [];
    operands.add(_dwOperand());

    while (_match(TokenType.comma)) {
      operands.add(_dwOperand());
    }

    return ast.DwDirective(
      label: label,
      dwToken: dwToken,
      operands: operands,
      comment: _comment()
    );
  }

  ast.DwOperand _dwOperand() {
    if (_check(TokenType.string)) {
      // String
      final Token stringToken = _advance();

      return ast.DwOperand(
        value: ast.StringLiteral(
          token: stringToken,
          value: stringToken.literal as String
        ),
        // String operands cannot use DUP
        dupToken: null,
        duplicate: null
      );
    } else {
      // Constant expression with possible DUP
      final ast.ConstExpression leftExpression = _constExpression();

      // Read DUP expression if it exists
      Token dupToken;
      ast.ConstExpression dupExpression;

      if (_check(TokenType.dup)) {
        dupToken = _advance();

        _consume(TokenType.leftParen, "Expected '(' to begin DUP expression.");

        dupExpression = _constExpression();

        _consume(TokenType.rightParen, "Expected ')' to end DUP expression.");
      }

      return ast.DwOperand(
        value: leftExpression,
        dupToken: dupToken,
        duplicate: dupExpression
      );
    }
  }

  ast.Instruction _instruction(ast.Label label, Token mnemonic) {
    // Read first operand
    final ast.InstructionOperand operand1 = _instructionOperand();

    // Read second operand if a comma is found
    Token comma;
    ast.InstructionOperand operand2;

    if (operand1 != null && _check(TokenType.comma)) {
      comma = _advance();

      operand2 = _instructionOperand();

      if (operand2 == null) {
        throw _error(_advance(), "Expected second instruction operand after ','.");
      }
    }

    // Build node
    return ast.Instruction(
      label: label,
      mnemonic: mnemonic,
      operand1: operand1,
      commaToken: comma,
      operand2: operand2,
      comment: _comment()
    );
  }

  ast.InstructionOperand _instructionOperand() {
    if (_check(TokenType.integer)) {
      // Integer
      final Token integerToken = _advance();

      return ast.InstructionExpressionOperand(
        ast.IntegerExpression(
          token: integerToken,
          value: integerToken.literal as int
        )
      );
    } else if (_check(TokenType.identifier)) {
      // Identifier
      return ast.InstructionExpressionOperand(
        ast.IdentifierExpression(
          identifier: _advance()
        )
      );
    } else if (_check(TokenType.leftBracket)) {
      // Memory
      final Token leftBracket = _advance();

      // Read memory value
      final ast.MemoryValue value = _memoryValue();

      // Read displacement if it exists
      Token displacementOperator;
      ast.MemoryValue displacement;

      if (!_check(TokenType.rightBracket)) {
        displacementOperator = _consumeAny(const [TokenType.minus, TokenType.plus],
          'Expected displacement operator'
        );

        displacement = _memoryValue();
      }

      // Consume "]"
      final Token rightBracket = _consume(TokenType.rightBracket,
        "Expected ']' to end memory expression."
      );

      return ast.MemoryReference(
        leftBracket: leftBracket,
        rightBracket: rightBracket,
        value: value,
        displacementOperator: displacementOperator,
        displacementValue: displacement
      );
    }

    return null;
  }

  ast.MemoryValue _memoryValue() {
    if (_check(TokenType.integer)) {
      // Integer
      final Token integerToken = _advance();

      return ast.IntegerExpression(
        token: integerToken,
        value: integerToken.literal as int
      );
    } else if (_check(TokenType.identifier)) {
      // Identifier
      return ast.IdentifierExpression(
        identifier: _advance()
      );
    }

    throw _error(_advance(), 'Expected memory value.');
  }

  ast.ConstExpression _constExpression() {
    return _constAddition();
  }

  ast.ConstExpression _constAddition() {
    ast.ConstExpression expression = _constUnary();

    while (_checkAny(const [TokenType.minus, TokenType.plus])) {
      final Token op = _advance();
      final ast.ConstExpression right = _constUnary();

      expression = ast.ConstBinaryExpression(
        left: expression,
        $operator: op,
        right: right
      );
    }

    return expression;
  }

  ast.ConstExpression _constUnary() {
    if (_check(TokenType.minus)) {
      final Token $operator = _advance();
      final ast.ConstExpression expression = _constUnary();

      return ast.ConstUnaryExpression(
        $operator: $operator,
        expression: expression
      );
    }

    return _constValue();
  }

  ast.ConstExpression _constValue() {
    if (_check(TokenType.integer)) {
      // Integer
      final Token integerToken = _advance();

      return ast.IntegerExpression(
        token: integerToken, 
        value: integerToken.literal as int
      );
    } else if (_check(TokenType.identifier)) {
      // Identifier
      return ast.IdentifierExpression(
        identifier: _advance()
      );
    } else if (_check(TokenType.leftParen)) {
      // Consume the '('
      final Token leftParen =_advance();

      // Grouping
      final ast.ConstExpression innerExpression = _constExpression();

      // Consume the ending ')'
      final Token rightParen = _consume(TokenType.rightParen, 
        "Expected ')' to end grouping expression."
      );

      return ast.ConstGroupExpression(
        leftParen: leftParen,
        expression: innerExpression,
        rightParen: rightParen
      );
    }

    throw _error(_advance(), 'Expected constant expression.');
  }

  /// Parses and returns a comment if it exists
  Token _comment() {
    if (_check(TokenType.comment)) {
      return _advance();
    } else {
      return null;
    }
  }

  _ParseException _error(Token token, String message) {
    _errors.add(AssembleError(token.sourceSpan, message));

    return _ParseException();
  }

  /// Checks if the current token is of the given [type].
  /// 
  /// If it does match, this method consumes it and returns `true`, otherwise it does
  /// not advance and returns `false`.
  bool _match(TokenType type) {
    if (_check(type)) {
      _advance();
      return true;
    }

    return false;
  }

  /// Consumes the current token if it is of the given [type]
  /// and returns the next token.
  /// 
  /// Otherwise, throws a [_ParseException] and adds an error
  /// with the given [errorMessage].
  Token _consume(TokenType type, String errorMessage) {
    if (_check(type)) {
      return _advance();
    }

    throw _error(_peek(), errorMessage);
  }

  /// Consumes the current token if it is of any of the given [types]
  /// and returns the next token.
  /// 
  /// Otherwise, throws a [_ParseException] and adds an error
  /// with the given [errorMessage].
  Token _consumeAny(List<TokenType> types, String errorMessage) {
    if (_checkAny(types)) {
      return _advance();
    }

    throw _error(_peek(), errorMessage);
  }

  /// Returns whether the current token is of the given [type].
  bool _check(TokenType type) {
    return _peek().type == type;
  }

  /// Returns whether the current token is of any of the given [types].
  bool _checkAny(List<TokenType> types) {
    final TokenType currentType = _peek().type;

    for (TokenType type in types) {
      if (type == currentType) {
        return true;
      }
    }

    return false;
  }

  /// Consumes the current token and returns it.
  Token _advance() {
    if (_isAtEnd()) {
      return _peek();
    } else {
      _current++;
      return _previous();
    }
  }

  bool _isAtEnd() {
    return _peek().type == TokenType.eof;
  }

  /// Returns the current token.
  Token _peek() {
    return _tokens[_current];
  }

  Token _previous() {
    return _tokens[_current - 1];
  }
}