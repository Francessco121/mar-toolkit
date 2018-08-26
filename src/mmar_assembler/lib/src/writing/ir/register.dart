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

Register stringToRegister(String string) {
  switch (string.toLowerCase()) {
    case 'a': return Register.a;
    case 'b': return Register.b;
    case 'c': return Register.c;
    case 'd': return Register.d;
    case 'x': return Register.x;
    case 'y': return Register.y;
    case 'bp': return Register.bp;
    case 'sp': return Register.sp;
  }

  return null;
}