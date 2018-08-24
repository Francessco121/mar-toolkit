import '../scanning/token.dart';
import '../scanning/token_type.dart';
import 'ast/ast.dart' as ast;
import 'parse_error.dart';
import 'parse_result.dart';

class _ParseException implements Exception { }

class Parser {
  int _current = 0;

  final List<ParseError> _errors = [];

  final List<Token> _tokens;

  Parser(this._tokens)
    : assert(_tokens != null);

  ParseResult parse() {
    List<ast.Line> lines = [];

    // Parse until EOF
    while (!_isAtEnd()) {
      // Parse line
      try {
        // Note: [line] will be null if it was just a newline character
        final ast.Line line = _line();

        if (line != null) {
          lines.add(line);
        }

        // Parse newline or EOF
        final Token token = _advance();
        if (token.type != TokenType.newline && token.type != TokenType.eof) {
          throw _error(token, 'Expected newline or end of file.');
        }
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
      lines: lines,
      errors: _errors
    );
  }

  ast.Line _line() {
    // Parse the inner node if it exists
    ast.Node innerNode;
    if (_check(TokenType.dot)) {
      // Section
      innerNode = _section(_advance());
    } else if (_check(TokenType.identifier)) {
      final Token identifier = _advance();

      if (_check(TokenType.equ)) {
        // Parse constant
        innerNode = _constant(identifier, _advance());
      } else {
        // Parse labelable
        innerNode = _labelable(identifier);
      }
    } else {
      // Directive
      innerNode = _directive();
    }

    // Parse the comment if it exists
    Token comment;
    if (_check(TokenType.comment)) {
      comment = _advance();
    }

    // Only return a node if an inner node or comment exists
    if (innerNode != null || comment != null) {
      return ast.Line(
        innerNode: innerNode,
        comment: comment
      );
    } else {
      return null;
    }
  }

  ast.Node _labelable(Token identifier) {
    // Parse the label if it exists
    ast.Label label;
    if (_check(TokenType.colon)) {
      label = _label(identifier, _advance());
    }

    if (_checkAny(const [TokenType.comment, TokenType.newline])) {
      // The line just contains a label (optionally with a comment)
      return label;
    } else {
      if (_check(TokenType.dw)) {
        // DW directives can be labeled
        return _dwDirective(label, _advance());
      } else {
        if (label != null) {
          // The identifier variable was used by the label, so we must consume
          // the instruction's mnemonic as the new identifier value
          identifier = _consume(TokenType.identifier, 'Expected instruction mnemonic.');
        }

        // Parse the instruction
        return _instruction(label, identifier);
      }
    }
  }

  ast.Node _directive() {
    if (_check(TokenType.org)) {
      // ORG directive
      return _orgDirective(_advance());
    } else if (_check(TokenType.dw)) {
      // Unlabeled DW directive
      return _dwDirective(null, _advance());
    }

    return null;
  }

  ast.Section _section(Token dotToken) {
    final Token identifier = _consume(TokenType.identifier,
      'Expected section identifier.'
    );

    return ast.Section(
      dotToken: dotToken,
      identifier: identifier
    );
  }

  ast.Constant _constant(Token identifier, Token equToken) {
    final ast.Expression expression = _constExpression();

    return ast.Constant(
      identifier: identifier,
      equToken: equToken,
      expression: expression
    );
  }

  ast.Label _label(Token identifier, Token colonToken) {
    return ast.Label(
      identifier: identifier,
      colonToken: colonToken
    );
  }

  ast.OrgDirective _orgDirective(Token orgToken) {
    final ast.Expression expression = _constExpression();

    return ast.OrgDirective(
      orgKeyword: orgToken,
      expression: expression
    );
  }

  ast.DwDirective _dwDirective(ast.Label label, Token dwToken) {
    final List<ast.Expression> expressions = [];
    expressions.add(_dwOperand());

    while (_match(TokenType.comma)) {
      expressions.add(_dwOperand());
    }

    return ast.DwDirective(
      label: label,
      dwToken: dwToken,
      expressions: expressions
    );
  }

  ast.Expression _dwOperand() {
    if (_check(TokenType.string)) {
      // String
      final Token stringToken = _advance();

      return ast.LiteralExpression(
        token: stringToken,
        value: stringToken.literal
      );
    } else {
      // Constant expression with possible DUP
      final ast.Expression leftExpression = _constExpression();

      // Read DUP expression if it exists
      Token dupToken;
      ast.Expression dupExpression;

      if (_check(TokenType.dup)) {
        dupToken = _advance();

        _consume(TokenType.leftParen, "Expected '(' to begin DUP expression.");

        dupExpression = _constExpression();

        _consume(TokenType.rightParen, "Expected ')' to end DUP expression.");
      }

      return ast.DwIntegerExpression(
        leftExpression: leftExpression,
        dupToken: dupToken,
        dupExpression: dupExpression
      );
    }
  }

  ast.Instruction _instruction(ast.Label label, Token mnemonic) {
    // Read first operand
    final ast.Expression operand1 = _instructionOperand();

    // Read second operand if a comma is found
    Token comma;
    ast.Expression operand2;

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
      operand2: operand2
    );
  }

  ast.Expression _instructionOperand() {
    if (_check(TokenType.integer)) {
      // Integer
      final Token integerToken = _advance();

      return ast.LiteralExpression(
        token: integerToken,
        value: integerToken.literal
      );
    } else if (_check(TokenType.identifier)) {
      // Identifier
      return ast.IdentifierExpression(
        identifier: _advance()
      );
    } else if (_check(TokenType.leftBracket)) {
      // Memory
      final Token leftBracket = _advance();

      // Read memory value
      final ast.Expression value = _memoryValue();

      // Read displacement if it exists
      Token displacementOperator;
      ast.Expression displacement;

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

      return ast.MemoryExpression(
        leftBracket: leftBracket,
        rightBracket: rightBracket,
        value: value,
        displacementOperator: displacementOperator,
        displacementValue: displacement
      );
    }

    return null;
  }

  ast.Expression _memoryValue() {
    if (_check(TokenType.integer)) {
      // Integer
      final Token integerToken = _advance();

      return ast.LiteralExpression(
        token: integerToken,
        value: integerToken.literal
      );
    } else if (_check(TokenType.identifier)) {
      // Identifier
      return ast.IdentifierExpression(
        identifier: _advance()
      );
    }

    throw _error(_advance(), 'Expected memory expression.');
  }

  ast.Expression _constExpression() {
    ast.Expression expression = _constValue();

    while (_checkAny(const [TokenType.minus, TokenType.plus])) {
      final Token op = _advance();
      final ast.Expression right = _constValue();

      expression = ast.ConstExpression(
        left: expression,
        operator_: op,
        right: right
      );
    }

    return expression;
  }

  ast.Expression _constValue() {
    if (_check(TokenType.integer)) {
      // Integer
      final Token integerToken = _advance();

      return ast.LiteralExpression(
        token: integerToken, 
        value: integerToken.literal
      );
    } else if (_check(TokenType.identifier)) {
      // Identifier
      return ast.IdentifierExpression(
        identifier: _advance()
      );
    }

    throw _error(_advance(), 'Expected constant expression.');
  }

  _ParseException _error(Token token, String message) {
    _errors.add(ParseError(
      token: token,
      message: message
    ));

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

  /// Checks if the current token is of any of the given [types].
  /// 
  /// If it does match, this method consumes it and returns `true`, otherwise it does
  /// not advance and returns `false`.
  bool _matchAny(List<TokenType> types) {
    if (_checkAny(types)) {
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
    if (_isAtEnd()) {
      return false;
    }

    return _peek().type == type;
  }

  /// Returns whether the current token is of any of the given [types].
  bool _checkAny(List<TokenType> types) {
    if (_isAtEnd()) {
      return false;
    }

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