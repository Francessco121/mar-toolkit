import 'dart:collection';

import 'package:charcode/charcode.dart';
import 'package:meta/meta.dart';
import 'package:source_span/source_span.dart';
import 'package:string_scanner/string_scanner.dart';

import '../mmar_error.dart';
import '../source.dart';
import '../token.dart';
import '../token_type.dart';

/// A map of literal keywords to their respected [TokenType].
const Map<String, TokenType> _keywords = {
  'dup': TokenType.dup,
  'dw': TokenType.dw,
  'equ': TokenType.equ,
  'org': TokenType.org
};

/// A map of literal macro keywords to their respected [TokenType].
const Map<String, TokenType> _macroKeywords = {
  'once': TokenType.once,
  'include': TokenType.include
};

/// A map of characters (which represent a single token as 1 character) 
/// to their respected [TokenType].
const Map<int, TokenType> _singleTokenTypes = {
  $colon: TokenType.colon,
  $comma: TokenType.comma,
  $dot: TokenType.dot,
  $slash: TokenType.forwardSlash,
  $lbracket: TokenType.leftBracket,
  $lparen: TokenType.leftParen,
  $minus: TokenType.minus,
  $percent: TokenType.percent,
  $plus: TokenType.plus,
  $rbracket: TokenType.rightBracket,
  $rparen: TokenType.rightParen,
  $asterisk: TokenType.star
};

/// Scans the MMAR [source] code into a list of [Token]s. 
ScanResult scan(Source source) {
  final scanner = _Scanner(source);
  
  return scanner.scan();
}

class ScanResult {
  final UnmodifiableListView<MmarError> errors;
  final UnmodifiableListView<Token> tokens;

  ScanResult({
    @required this.tokens,
    @required this.errors
  });
}

class _Scanner {
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
  final List<MmarError> _errors = [];
  final StringBuffer _lexemeBuffer = StringBuffer();

  final StringScanner _scanner;

  _Scanner(Source source)
    : assert(source != null),
      _scanner = StringScanner(source.contents, sourceUrl: source.uri);

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
      tokens: UnmodifiableListView(_tokens),
      errors: UnmodifiableListView(_errors)
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
        case $hash:
          _macroKeyword();
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
            _addError('Unexpected character.');
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
    bool justEscaped = false;
    int _lastChar;
    while (!_isAtEnd()) {
      // Deal with escaped double quotes
      if (!justEscaped && _lastChar == $backslash) {
        justEscaped = true;
      } else if (_peek() == $quote) {
        break;
      } else {
        justEscaped = false;
      }

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
      _addError('Unterminated string.');
      return;
    }

    // Consume the closing '"'
    _advance();
    _currentOffset++;
    _currentColumn++;

    // Build the lexeme
    final String lexeme = _lexemeBuffer.toString();

    // Convert the lexeme to a string literal (removes quotes and handles escape codes)
    final String literal = _stringLexemeToLiteral(lexeme);
    
    // Create start and end source locations
    final SourceSpan span = _createSourceSpanForCurrent(lexeme);

    // Manually add the token
    _tokens.add(Token(
      type: TokenType.string,
      literal: literal,
      sourceSpan: span
    ));
  }

  String _stringLexemeToLiteral(String lexeme) {
    // Track our own temporary character positions so we can
    // create source spans for escape sequences
    int currentOffset = _startOffset;
    int currentColumn = _currentColumn;
    int currentLine = _currentLine;

    // Trim surrounding quotes and handle escape characters
    final StringBuffer buffer = new StringBuffer();

    int prevChar = null;
    bool justEscaped = false;

    for (int i = 1; i < lexeme.length - 1; i++) {
      final int char = lexeme.codeUnitAt(i);

      if (char == $lf) {
        currentColumn = 0;
        currentLine++;
      } else {
        currentOffset++;
        currentColumn++;
      }

      currentOffset++;

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
          // \f
          case $f:
            buffer.writeCharCode($ff);
            break;
          // \0
          case $0:
            buffer.writeCharCode($nul);
            break;
          default:
            _addError('Unexpected escape sequence.', 
              span: SourceSpan(
                SourceLocation(
                  currentOffset - 1,
                  column: currentColumn - 1,
                  line: currentLine,
                  sourceUrl: _scanner.sourceUrl
                ),
                SourceLocation(
                  currentOffset + 1,
                  column: currentColumn + 1,
                  line: currentLine,
                  sourceUrl: _scanner.sourceUrl
                ),
                lexeme.substring(i - 1, i + 1)
              )
            );
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
    return buffer.toString();
  }

  void _integer(int firstChar) {
    int literal;

    try {
      // Look for base prefixes first
      if (firstChar == $0 && _peek() == $x) {
        // Hexadecimal

        // Consume the 'x'
        _advance();

        // Read hex number
        while (_isBase16Digit(_peek()) || _peek() == $underscore) {
          _advance();
        }

        // Build the literal string
        final String literalString = _lexemeBuffer.toString()
          .substring(2)
          .replaceAll('_', '');
        
        // Convert the number
        literal = int.parse(literalString, radix: 16);
      } else if (firstChar == $0 && _peek() == $b) {
        // Binary

        // Consume the 'b'
        _advance();

        // Read binary number
        while (_isBase2Digit(_peek()) || _peek() == $underscore) {
          _advance();
        }

        // Build the literal string
        final String literalString = _lexemeBuffer.toString()
          .substring(2)
          .replaceAll('_', '');
        
        // Convert the number
        literal = int.parse(literalString, radix: 2);
      } else {
        // Decimal

        // Read base 10 number
        while (_isBase10Digit(_peek()) || _peek() == $underscore) {
          _advance();
        }

        // Build the literal string
        final String literalString = _lexemeBuffer.toString()
          .replaceAll('_', '');

        // Convert the number
        literal = int.parse(literalString);
      }
    } on FormatException { /* Integer was not valid or overflowed. */ }

    // Add the token
    _addToken(TokenType.integer, literal: literal ?? 0);

    // Note: Do this after adding the token so the character positions are correct for the source span
    if (literal == null) {
      _addError(
        'Integer literal cannot be larger than the maximum signed 64-bit value.'
      );
    }
  }

  void _identifierOrKeyword() {
    // Read all alpha-numeric characters
    while (_isAlphaNumeric(_peek())) {
      _advance();
    }

    final String text = _lexemeBuffer.toString();

    // Check if the text is a keyword, otherwise fallback to an identifier
    final TokenType type = _keywords[text.toLowerCase()] ?? TokenType.identifier;

    // Add the token
    _addToken(type, currentLexeme: text);
  }

  void _macroKeyword() {
    // Read all alpha characters
    while (_isAlpha(_peek())) {
      _advance();
    }

    final String lexeme = _lexemeBuffer.toString();

    // Strip off leading '#'
    final String macroText = lexeme.substring(1);

    // Map the string literal to a macro keyword
    final TokenType type = _macroKeywords[macroText.toLowerCase()];

    if (type == null) {
      _addError('Unknown macro.');
    } else {
      _addToken(type, currentLexeme: lexeme);
    }
  }

  void _addError(String message, {SourceSpan span}) {
    span ??= _createSourceSpanForCurrent();

    _errors.add(MmarError(span, message));
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