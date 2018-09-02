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

/// A map of registers to their bytecode index.
/// 
/// These indexes are used when encoding instruction selectors.
const Map<Register, int> registerIndexes = {
  Register.a: 1,
  Register.b: 2,
  Register.c: 3,
  Register.d: 4,
  Register.x: 5,
  Register.y: 6,
  Register.sp: 7,
  Register.bp: 8
};

/// A map of register byte code indexes to their respected
/// enum value.
const Map<int, Register> indexesToRegisters = {
  1: Register.a,
  2: Register.b,
  3: Register.c,
  4: Register.d,
  5: Register.x,
  6: Register.y,
  7: Register.sp,
  8: Register.bp
};

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