import 'instruction_definition.dart';
import 'instructions.dart';

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
  final InstructionDefinition def = mnemonicsToInstructionDefs[mnemonic];

  return def?.mnemonicText;
}

Mnemonic stringToMnemonic(String string) {
  string = string.toLowerCase();

  for (InstructionDefinition def in instructionDefinitions) {
    if (def.mnemonicText == string) {
      return def.mnemonic;
    }
  }

  return null;
}