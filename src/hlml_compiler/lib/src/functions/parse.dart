import 'dart:collection';

import 'package:meta/meta.dart';

import '../ast/ast.dart';
import '../hlml_problem.dart';
import '../token.dart';
import '../token_type.dart';

/// Parses the list of MMAR [tokens] into a list of AST [Statement]s.
ParseResult parse(List<Token> tokens) {
  final parser = _Parser(tokens);
  
  return parser.parse();
}

class ParseResult {
  final HlmlProblems problems;
  final UnmodifiableListView<Statement> statements;

  ParseResult({
    @required this.statements,
    @required this.problems
  })
    : assert(statements != null),
      assert(problems != null);
}

class _ParseException implements Exception { }

class _Parser {
  int _current = 0;

  final _problems = new HlmlProblemsBuilder();

  final List<Token> _tokens;

  _Parser(this._tokens)
    : assert(_tokens != null);

  ParseResult parse() {
    final List<Statement> statements = [];

    // Parse until EOF
    while (!_isAtEnd()) {
      // Parse statement
      try {
        statements.add(_statement());
      } on _ParseException {
        // Skip until newline or EOF
        while (true) {
          final Token token = _advance();

          if (token.type == TokenType.semicolon || token.type == TokenType.eof) {
            break;
          }
        }
      }
    }

    // Parse complete!
    return ParseResult(
      statements: UnmodifiableListView(statements),
      problems: _problems.build()
    );
  }

  Statement _statement() {
    if (_check(TokenType.entry)) {
      return _entry();
    } else if (_checkAny(const [TokenType.$var, TokenType.let])) {
      return _variableDeclaration();
    }

    return _expressionStatement();
  }

  Entry _entry() {
    // Consume keyword
    _advance();

    // Parse '{'
    _consume(TokenType.leftBrace, "Expected '{' to begin entry block.");

    // Parse body
    final body = <Statement>[];

    while (!_match(TokenType.rightBrace)) {
      body.add(_statement());
    }

    return Entry(body);
  }

  VariableDeclaration _variableDeclaration() {
    // Determine declaration type
    final Token typeToken = _advance();

    final VariableDeclarationType type = typeToken.type == TokenType.$var
      ? VariableDeclarationType.mutable
      : VariableDeclarationType.immutable;

    // Parse identifier
    final Token identifier = _consume(TokenType.identifier, 'Expected variable identifier.');

    // Parse ':'
    _consume(TokenType.colon, "Expected ':' to begin variable type.");

    // Parse type
    final Token typeIdentifier = _consume(TokenType.identifier, 'Expected variable type.');

    // Parse '='
    _consume(TokenType.equal, "Expected '=' to begin variable declaration initializer.");

    // Parse initializer
    final Expression initializer = _expression();

    // Parse ';'
    _consume(TokenType.semicolon, "Expected ';' to end variable declaration initializer.");

    // All set!
    return VariableDeclaration(
      type: type,
      identifier: identifier,
      typeIdentifier: typeIdentifier,
      initializer: initializer
    );
  }

  ExpressionStatement _expressionStatement() {
    final Expression expression = _expression();

    _consume(TokenType.semicolon, "Expected ';' after expression.");

    return ExpressionStatement(expression);
  }

  Expression _expression() {
    return _primary();
  }

  Expression _primary() {
    if (_check(TokenType.integer)) {
      final Token token = _advance();

      return LiteralExpression(LiteralType.integer, token.literal, token);
    }
    
    if (_check(TokenType.$true)) return LiteralExpression(LiteralType.boolean, true, _advance());
    if (_check(TokenType.$false)) return LiteralExpression(LiteralType.boolean, false, _advance());

    throw _error(_advance(), 'Expected expression.');
  }

  _ParseException _error(Token token, String message) {
    _problems.addError(token.sourceSpan, message);

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