enum TokenType {
  // Symbols
  colon,
  comma,
  dot,
  forwardSlash,
  leftBracket,
  leftParen,
  minus,
  percent,
  plus,
  rightBracket,
  rightParen,
  star,

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
  include,
  once,
  org,

  // End-of-file
  eof
}