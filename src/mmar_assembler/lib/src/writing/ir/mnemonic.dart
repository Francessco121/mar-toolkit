enum Mnemonic {
  add,
  and,
  brk,
  call,
  cmp,
  dec,
  div,
  hwi,
  hwq,
  inc,
  ja,
  jc,
  jg,
  jge,
  jl,
  jle,
  jmp,
  jna,
  jnc,
  jno,
  jns,
  jnz,
  jo,
  js,
  jz,
  mov,
  mul,
  neg,
  nop,
  not,
  or,
  pop,
  popf,
  push,
  pushf,
  rcl,
  rcr,
  ret,
  rol,
  ror,
  sal,
  sar,
  shl,
  shr,
  sub,
  test,
  xchg,
  xor
}

String mnemonicToString(Mnemonic mnemonic) {
  switch (mnemonic) {
    case Mnemonic.add: return 'add';
    case Mnemonic.and: return 'and';
    case Mnemonic.brk: return 'brk';
    case Mnemonic.call: return 'call';
    case Mnemonic.cmp: return 'cmp';
    case Mnemonic.dec: return 'dec';
    case Mnemonic.div: return 'div';
    case Mnemonic.hwi: return 'hwi';
    case Mnemonic.hwq: return 'hwq';
    case Mnemonic.inc: return 'inc';
    case Mnemonic.ja: return 'ja';
    case Mnemonic.jc: return 'jc';
    case Mnemonic.jg: return 'jg';
    case Mnemonic.jge: return 'jge';
    case Mnemonic.jl: return 'jl';
    case Mnemonic.jle: return 'jle';
    case Mnemonic.jmp: return 'jmp';
    case Mnemonic.jna: return 'jna';
    case Mnemonic.jnc: return 'jnc';
    case Mnemonic.jno: return 'jno';
    case Mnemonic.jns: return 'jns';
    case Mnemonic.jnz: return 'jnz';
    case Mnemonic.jo: return 'jo';
    case Mnemonic.js: return 'js';
    case Mnemonic.jz: return 'jz';
    case Mnemonic.mov: return 'mov';
    case Mnemonic.mul: return 'mul';
    case Mnemonic.neg: return 'neg';
    case Mnemonic.nop: return 'nop';
    case Mnemonic.not: return 'not';
    case Mnemonic.or: return 'or';
    case Mnemonic.pop: return 'pop';
    case Mnemonic.popf: return 'popf';
    case Mnemonic.push: return 'push';
    case Mnemonic.pushf: return 'pushf';
    case Mnemonic.rcl: return 'rcl';
    case Mnemonic.rcr: return 'rcr';
    case Mnemonic.ret: return 'ret';
    case Mnemonic.rol: return 'rol';
    case Mnemonic.ror: return 'ror';
    case Mnemonic.sal: return 'sal';
    case Mnemonic.sar: return 'sar';
    case Mnemonic.shl: return 'shl';
    case Mnemonic.shr: return 'shr';
    case Mnemonic.sub: return 'sub';
    case Mnemonic.test: return 'test';
    case Mnemonic.xchg: return 'xchg';
    case Mnemonic.xor: return 'xor';
  }

  // Should never happen
  throw ArgumentError.value(mnemonic, 'mnemonic');
}