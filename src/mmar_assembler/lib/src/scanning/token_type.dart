enum TokenType {
  // Symbols
  colon,
  comma,
  dot,
  leftBracket,
  leftParen,
  minus,
  plus,
  rightBracket,
  rightParen,

  // Literals
  comment,
  identifier,
  integer,
  newline,
  string,

  // Keywords
  dup,
  dw,
  equ,
  org,

  // End-of-file
  eof
}