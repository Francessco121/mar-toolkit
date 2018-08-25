enum Register {
  a,
  b,
  c,
  d,
  x,
  y,
  bp,
  sp
}

String registerToString(Register register) {
  switch (register) {
    case Register.a: return 'a';
    case Register.b: return 'b';
    case Register.c: return 'c';
    case Register.d: return 'd';
    case Register.x: return 'x';
    case Register.y: return 'y';
    case Register.bp: return 'bp';
    case Register.sp: return 'sp';
  }

  // Should never happen
  throw ArgumentError.value(register, 'register');
}