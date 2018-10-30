import 'dart:collection';

import 'package:charcode/charcode.dart';
import 'package:meta/meta.dart';
import 'package:source_span/source_span.dart';
import 'package:string_scanner/string_scanner.dart';

import '../hlml_problem.dart';
import '../source.dart';
import '../token.dart';
import '../token_type.dart';

/// A map of literal keywords to their respected [TokenType].
const Map<String, TokenType> _keywords = {
  'true': TokenType.$true,
  'false': TokenType.$false,
  'var': TokenType.$var,
  'let': TokenType.let,
  'entry': TokenType.entry,
  'undefined': TokenType.undefined,
  'fn': TokenType.fn,
  'return': TokenType.$return,
  'if': TokenType.$if,
  'else': TokenType.$else,
  'loop': TokenType.loop,
  'while': TokenType.$while,
  'do': TokenType.$do,
  'break': TokenType.$break,
  'continue': TokenType.$continue,
  'sleep': TokenType.sleep
};

/// Scans the HLML [source] code into a list of [Token]s. 
ScanResult scan(Source source) {
  final scanner = _Scanner(source);
  
  return scanner.scan();
}

class ScanResult {
  final UnmodifiableListView<Token> tokens;
  final HlmlProblems problems;

  ScanResult({
    @required this.tokens,
    @required this.problems
  }) {
    if (tokens == null) throw ArgumentError.notNull('tokens');
    if (problems == null) throw ArgumentError.notNull('problems');
  }
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
  final _problems = new HlmlProblemsBuilder();
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
      problems: _problems.build()
    );
  }

  void _scanToken() {
    // Read the next character
    int char = _advance();

    // Reset the starting positions
    _startOffset = _currentOffset;
    _startColumn = _currentColumn;
    _startLine = _currentLine;

    // Handle character
    switch (char) {
      case $colon: _addToken(TokenType.colon); break;
      case $semicolon: _addToken(TokenType.semicolon); break;
      case $comma: _addToken(TokenType.comma); break;
      case $dot: _addToken(TokenType.dot); break;
      case $lbrace: _addToken(TokenType.leftBrace); break;
      case $rbrace: _addToken(TokenType.rightBrace); break;
      case $lparen: _addToken(TokenType.leftParen); break;
      case $rparen: _addToken(TokenType.rightParen); break;
      case $plus: _addToken(TokenType.plus); break;
      case $percent: _addToken(TokenType.percent); break;
      case $asterisk: _addToken(TokenType.star); break;
      case $caret: _addToken(TokenType.caret); break;
      case $tilde: _addToken(TokenType.tilde); break;
      case $minus:
        if (_match($greater_than)) _addToken(TokenType.thinArrow);
        else _addToken(TokenType.minus); 
        
        break;
      case $less_than:
        if (_match($less_than)) _addToken(TokenType.lessLess);
        else if (_match($equal)) _addToken(TokenType.lessEqual);
        else _addToken(TokenType.less);
        
        break;
      case $greater_than:
        if (_match($greater_than)) _addToken(TokenType.greaterGreater);
        else if (_match($equal)) _addToken(TokenType.greaterEqual);
        else _addToken(TokenType.greater);
        
        break;
      case $amp:
        if (_match($amp)) _addToken(TokenType.ampAmp);
        else _addToken(TokenType.amp);
        
        break;
      case $pipe:
        if (_match($pipe)) _addToken(TokenType.pipePipe);
        else _addToken(TokenType.pipe);
        
        break;
      case $equal:
        if (_match($equal)) _addToken(TokenType.equalEqual);
        else _addToken(TokenType.equal);
        
        break;
      case $exclamation:
        if (_match($equal)) _addToken(TokenType.bangEqual);
        else _addToken(TokenType.bang);
        
        break;
      case $slash:
        if (_match($slash)) _comment();
        else _addToken(TokenType.forwardSlash);

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
        _currentOffset++;
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

  void _comment() {
    // A comment goes until the end of the line

    // Read entire comment
    while (_peek() != $lf && !_isAtEnd()) {
      _advance();
    }
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

  void _addError(String message, {SourceSpan span}) {
    span ??= _createSourceSpanForCurrent();

    _problems.addError(span, message);
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

  bool _match(int char) {
    if (_peek() == char) {
      _advance();
      return true;
    }

    return false;
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
