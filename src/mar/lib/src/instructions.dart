import 'instruction_definition.dart';
import 'mnemonic.dart';
import 'operand_type_flags.dart';

/// A list of all supported MAR instructions.
final List<InstructionDefinition> instructionDefinitions = [
  //      Mnemonic        Text      Opcode  Valid operand 1 types                 Valid operand 2 types
  _define(Mnemonic.add,   'add',    0x02,   [memoryOp, registerOp],               [memoryOp, registerOp, immediateOp] ),
  _define(Mnemonic.and,   'and',    0x04,   [memoryOp, registerOp],               [memoryOp, registerOp, immediateOp] ),
  _define(Mnemonic.brk,   'brk',    0x00,   null,                                 null                                ),
  _define(Mnemonic.call,  'call',   0x15,   [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.cmp,   'cmp',    0x0C,   [memoryOp, registerOp],               [memoryOp, registerOp, immediateOp] ),
  _define(Mnemonic.dec,   'dec',    0x2B,   [memoryOp, registerOp],               null                                ),
  _define(Mnemonic.div,   'div',    0x18,   [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.hwi,   'hwi',    0x09,   [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.hwq,   'hwq',    0x1C,   [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.inc,   'inc',    0x2A,   [memoryOp, registerOp],               null                                ),
  _define(Mnemonic.ja,    'ja',     0x2E,   [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.jc,    'jc',     0x21,   [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.jg,    'jg',     0x0F,   [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.jge,   'jge',    0x10,   [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.jl,    'jl',     0x11,   [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.jle,   'jle',    0x12,   [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.jmp,   'jmp',    0x0A,   [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.jna,   'jna',    0x2F,   [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.jnc,   'jnc',    0x22,   [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.jno,   'jno',    0x25,   [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.jns,   'jns',    0x1B,   [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.jnz,   'jnz',    0x0D,   [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.jo,    'jo',     0x24,   [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.js,    'js',     0x1A,   [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.jz,    'jz',     0x0E,   [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.mov,   'mov',    0x01,   [memoryOp, registerOp],               [memoryOp, registerOp, immediateOp] ),
  _define(Mnemonic.mul,   'mul',    0x17,   [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.neg,   'neg',    0x19,   [memoryOp, registerOp],               null                                ),
  _define(Mnemonic.nop,   'nop',    0x3F,   null,                                 null                                ),
  _define(Mnemonic.not,   'not',    0x1D,   [memoryOp, registerOp],               null                                ),
  _define(Mnemonic.or,    'or',     0x05,   [memoryOp, registerOp],               [memoryOp, registerOp, immediateOp] ),
  _define(Mnemonic.pop,   'pop',    0x14,   [memoryOp, registerOp],               null                                ),
  _define(Mnemonic.popf,  'popf',   0x2C,   null,                                 null                                ),
  _define(Mnemonic.push,  'push',   0x13,   [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.pushf, 'pushf',  0x2D,   null,                                 null                                ),
  _define(Mnemonic.rcl,   'rcl',    0x27,   [memoryOp, registerOp],               [memoryOp, registerOp, immediateOp] ),
  _define(Mnemonic.rcr,   'rcr',    0x28,   [memoryOp, registerOp],               [memoryOp, registerOp, immediateOp] ),
  _define(Mnemonic.ret,   'ret',    0x16,   [immediateOp, noOp],                  null                                ),
  _define(Mnemonic.rol,   'rol',    0x23,   [memoryOp, registerOp],               [memoryOp, registerOp, immediateOp] ),
  _define(Mnemonic.ror,   'ror',    0x20,   [memoryOp, registerOp],               [memoryOp, registerOp, immediateOp] ),
  _define(Mnemonic.sal,   'sal',    0x06,   [memoryOp, registerOp],               [memoryOp, registerOp, immediateOp] ),
  _define(Mnemonic.sar,   'sar',    0x29,   [memoryOp, registerOp],               [memoryOp, registerOp, immediateOp] ),
  _define(Mnemonic.shl,   'shl',    0x06,   [memoryOp, registerOp],               [memoryOp, registerOp, immediateOp] ),
  _define(Mnemonic.shr,   'shr',    0x07,   [memoryOp, registerOp],               [memoryOp, registerOp, immediateOp] ),
  _define(Mnemonic.sub,   'sub',    0x03,   [memoryOp, registerOp],               [memoryOp, registerOp, immediateOp] ),
  _define(Mnemonic.test,  'test',   0x0B,   [memoryOp, registerOp],               [memoryOp, registerOp, immediateOp] ),
  _define(Mnemonic.xchg,  'xchg',   0x1F,   [memoryOp, registerOp],               [memoryOp, registerOp]              ),
  _define(Mnemonic.xor,   'xor',    0x26,   [memoryOp, registerOp],               [memoryOp, registerOp, immediateOp] ),
];

/// A map of [Mnemonic] enum values to their respected [InstructionDefinition].
final Map<Mnemonic, InstructionDefinition> mnemonicsToInstructionDefs = _createMnemonicMap();

/// A map of opcodes to their respected [InstructionDefinition].
final Map<int, InstructionDefinition> opcodesToInstructionDefs = _createOpcodeMap();

Map<Mnemonic, InstructionDefinition> _createMnemonicMap() {
  final Map<Mnemonic, InstructionDefinition> map = {};

  for (InstructionDefinition def in instructionDefinitions) {
    map[def.mnemonic] = def;
  }

  return map;
}

Map<int, InstructionDefinition> _createOpcodeMap() {
  final Map<int, InstructionDefinition> map = {};

  for (InstructionDefinition def in instructionDefinitions) {
    map[def.opcode] = def;
  }

  return map;
}

InstructionDefinition _define(
  Mnemonic mnemonic, 
  String mnemonicText,
  int opcode,
  List<int> validOperand1Types,
  List<int> validOperand2Types
) {
  assert(mnemonic != null);
  assert(mnemonicText != null);
  assert(opcode != null);

  return InstructionDefinition(
    mnemonic: mnemonic,
    mnemonicText: mnemonicText,
    opcode: opcode,
    operand1: InstructionOperandDefintion(validOperand1Types),
    operand2: InstructionOperandDefintion(validOperand2Types)
  );
}
