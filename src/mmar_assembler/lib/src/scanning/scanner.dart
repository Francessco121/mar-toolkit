import 'package:charcode/charcode.dart';
import 'package:source_span/source_span.dart';
import 'package:string_scanner/string_scanner.dart';

import 'scan_error.dart';
import 'scan_result.dart';
import 'token.dart';
import 'token_type.dart';

/// A map of literal keywords to their respected [TokenType].
const Map<String, TokenType> _keywords = const {
  'dup': TokenType.dup,
  'dw': TokenType.dw,
  'equ': TokenType.equ,
  'org': TokenType.org
};

/// A map of characters (which represent a single token as 1 character) 
/// to their respected [TokenType].
const Map<int, TokenType> _singleTokenTypes = const {
  $colon: TokenType.colon,
  $comma: TokenType.comma,
  $dot: TokenType.dot,
  $lbracket: TokenType.leftBracket,
  $lparen: TokenType.leftParen,
  $minus: TokenType.minus,
  $plus: TokenType.plus,
  $rbracket: TokenType.rightBracket,
  $rparen: TokenType.rightParen
};

class Scanner {
  /// The offset which [_lexemeBuffer] currently starts at.
  int _startOffset;
  /// The column which [_lexemeBuffer] currently starts at.
  int _startColumn;
  /// The line which [_lexemeBuffer] currently starts at.
  int _startLine;

  int _currentOffset = 0;
  int _currentLine = 0;
  int _currentColumn = 0;

  int _current;

  final List<Token> _tokens = [];
  final List<ScanError> _errors = [];
  final StringBuffer _lexemeBuffer = StringBuffer();

  final StringScanner _scanner;

  Scanner(String content, Uri uri)
    : assert(content != null),
      assert(uri != null),
      _scanner = StringScanner(content, sourceUrl: uri);

  ScanResult scan() {
    // Prep
    _current = _read();

    // Read until EOF
    while (!_isAtEnd()) {
      _lexemeBuffer.clear();
      _scanToken();
    }

    // Add EOF token
    final location = SourceLocation(
      _currentOffset,
      column: _currentColumn,
      line: _currentLine,
      sourceUrl: _scanner.sourceUrl
    );

    _tokens.add(Token(
      sourceSpan: SourceSpan(location, location, ''),
      type: TokenType.eof
    ));

    // Scan complete!
    return ScanResult(
      tokens: _tokens,
      errors: _errors
    );
  }

  void _scanToken() {
    // Read the next character
    int char = _advance();

    // Reset the starting positions
    _startOffset = _currentOffset;
    _startColumn = _currentColumn;
    _startLine = _currentLine;

    // Handle single token types
    TokenType singleTokenType = _singleTokenTypes[char];
    if (singleTokenType != null) {
      _addToken(singleTokenType);
    } else {
      // Handle more complex tokens
      switch (char) {
        case $semicolon:
          _comment();
          break;
        case $quote:
          _string();
          break;
        case $space:
        case $tab:
          // Visible whitespace
          _currentOffset++;
          _currentColumn++;
          break;
        case $cr:
          // Invisible whitespace
          break;
        case $lf:
          // Newline
          _addToken(TokenType.newline);
          // Note: _addToken handles incrementing _currentPosition
          _currentColumn = 0;
          _currentLine++;
          break;
        default:
          if (_isBase10Digit(char)) {
            _integer(char);
          } else if (_isAlpha(char)) {
            _identifierOrKeyword();
          } else {
            _currentOffset++;
            _currentColumn++;
            _addError("Unexpected character.");
          }

          break;
      }
    }
  }

  void _comment() {
    // A comment goes until the end of the line

    // Read entire comment
    while (_peek() != $lf && !_isAtEnd()) {
      _advance();
    }

    // Build the lexeme
    final String lexeme = _lexemeBuffer.toString();

    // Strip off ';' and whitespace to get the literal
    final String literal = lexeme
      .substring(1)
      .trim();

    // Add the token
    _addToken(TokenType.comment,
      literal: literal,
      currentLexeme: lexeme
    );
  }

  void _string() {
    // Note: We manually increment positions here because strings can be multiline,
    // and [_addToken] does not handle newlines.

    // Handle the starting '"'
    _currentOffset++;
    _currentColumn++;

    // Read until end of string or EOF
    int _lastChar;
    while ((_peek() != $quote || _lastChar == $backslash) && !_isAtEnd()) {
      _currentOffset++;

      if (_peek() == $lf) {
        _currentLine++;
        _currentColumn = 0;
      } else {
        _currentColumn++;
      }

      _lastChar = _advance();
    }

    // Check if it's an unterminated string
    if (_isAtEnd()) {
      _addError("Unterminated string.");
      return;
    }

    // Consume the closing '"'
    _advance();
    _currentOffset++;
    _currentColumn++;

    // Build the lexeme
    final String lexeme = _lexemeBuffer.toString();

    // Trim surrounding quotes and handle escape characters
    final StringBuffer buffer = new StringBuffer();

    int prevChar = null;
    bool justEscaped = false;

    for (int i = 1; i < lexeme.length - 1; i++) {
      final int char = lexeme.codeUnitAt(i);

      if (!justEscaped && prevChar == $backslash) {
        switch (char) {
          // \\
          case $backslash:
            buffer.writeCharCode($backslash);
            break;
          // \"
          case $quote:
            buffer.writeCharCode($quote);
            break;
          // \b
          case $b:
            buffer.writeCharCode($bs);
            break;
          // \n
          case $n:
            buffer.writeCharCode($lf);
            break;
          // \r
          case $r:
            buffer.writeCharCode($cr);
            break;
          // \t
          case $t:
            buffer.writeCharCode($tab);
            break;
          // \0
          case $0:
            buffer.writeCharCode($nul);
            break;
          default:
            // TODO: This error should mark the actual character (and backslash) with the source span
            _addError("Unexpected escape character '${String.fromCharCode(char)}'.");
            break;
        }

        justEscaped = true;
      } else {
        if (char != $backslash) {
          buffer.writeCharCode(char);
        }

        justEscaped = false;
      }

      prevChar = char;
    }

    // Build the literal value
    final String literal = buffer.toString();
    
    // Create start and end source locations
    final SourceSpan span = _createSourceSpanForCurrent(lexeme);

    // Manually add the token
    _tokens.add(Token(
      type: TokenType.string,
      literal: literal,
      sourceSpan: span
    ));
  }

  void _integer(int firstChar) {
    // TODO: Handle format exceptions and overflows
    //       Should probably enforce 16-bit values too

    int literal;

    // Look for base prefixes first
    if (firstChar == $0 && _peek() == $x) {
      // Hexadecimal

      // Consume the 'x'
      _advance();

      // Read hex number
      while (_isBase16Digit(_peek())) {
        _advance();
      }

      // Build the literal string
      final String literalString = _lexemeBuffer.toString()
        .substring(2);
      
      // Convert the number
      literal = int.parse(literalString, radix: 16);
    } else if (firstChar == $0 && _peek() == $b) {
      // Binary

      // Consume the 'b'
      _advance();

      // Read binary number
      while (_isBase2Digit(_peek())) {
        _advance();
      }

      // Build the literal string
      final String literalString = _lexemeBuffer.toString()
        .substring(2);
      
      // Convert the number
      literal = int.parse(literalString, radix: 2);
    } else {
      // Decimal

      // Read base 10 number
      while (_isBase10Digit(_peek())) {
        _advance();
      }

      // Build the literal string
      final String literalString = _lexemeBuffer.toString();

      // Convert the number
      literal = int.parse(literalString);
    }

    // Add the token
    _addToken(TokenType.integer, literal: literal);
  }

  void _identifierOrKeyword() {
    // Read all alpha-numeric characters
    while (_isAlphaNumeric(_peek())) {
      _advance();
    }

    final String text = _lexemeBuffer.toString();

    // Check if the text is a keyword, otherwise fallback to an identifier
    TokenType type = _keywords[text.toLowerCase()] ?? TokenType.identifier;

    // Add the token
    _addToken(type, currentLexeme: text);
  }

  void _addError(String message, {SourceSpan span}) {
    span ??= _createSourceSpanForCurrent();

    _errors.add(ScanError(
      message: message,
      sourceSpan: span
    ));
  }

  /// Pass the [currentLexeme] if it has already been read to avoid redundency,
  /// otherwise this call will build it from the [_lexemeBuffer].
  void _addToken(TokenType type, {Object literal, String currentLexeme}) {
    // Build the lexeme if not already build
    currentLexeme ??= _lexemeBuffer.toString();

    // Increment the column and offset position
    _currentOffset += currentLexeme.length;
    _currentColumn += currentLexeme.length;

    // Create start and end source locations
    final SourceSpan span = _createSourceSpanForCurrent(currentLexeme);

    // Add the token
    _tokens.add(Token(
      type: type,
      literal: literal,
      sourceSpan: span
    ));
  }

  /// Creates a [SourceSpan] representing the current scanner positions.
  /// 
  /// Pass the [currentLexeme] if it has already been read to avoid redundency,
  /// otherwise this call will build it from the [_lexemeBuffer].
  SourceSpan _createSourceSpanForCurrent([String currentLexeme]) {
    return SourceSpan(
      SourceLocation(_startOffset,
        column: _startColumn,
        line: _startLine,
        sourceUrl: _scanner.sourceUrl
      ),
      SourceLocation(_currentOffset,
        column: _currentColumn,
        line: _currentLine,
        sourceUrl: _scanner.sourceUrl
      ),
      currentLexeme ?? _lexemeBuffer.toString()
    );
  }

  bool _isAlpha(int char) {
    return (char >= $a && char <= $z)
      || (char >= $A && char <= $Z)
      || char == $_;
  }

  bool _isBase2Digit(int char) {
    return char == $0 || char == $1;
  }

  bool _isBase10Digit(int char) {
    return char >= $0 && char <= $9;
  }

  bool _isBase16Digit(int char) {
    return _isBase10Digit(char)
      || (char >= $a && char <= $f)
      || (char >= $A && char <= $F);
  }

  bool _isAlphaNumeric(int char) {
    return _isAlpha(char) || _isBase10Digit(char);
  }

  int _advance() {
    int char = _current;
    _current = _read();

    _lexemeBuffer.writeCharCode(char);
    return char;
  }

  int _peek() {
    return _current;
  }

  int _read() {
    return _scanner.isDone ? -1 : _scanner.readChar();
  }

  bool _isAtEnd() {
    return _current == -1;
  }
}