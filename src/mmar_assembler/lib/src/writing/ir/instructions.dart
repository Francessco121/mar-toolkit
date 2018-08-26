import 'instruction_definition.dart';
import 'mnemonic.dart';
import 'operand_type_flags.dart';

/// A list of all supported MAR instructions.
final List<InstructionDefinition> instructionDefinitions = [
  //      Mnemonic        Text      Valid operand 1 types                 Valid operand 2 types
  _define(Mnemonic.add,   'add',    [memoryOp, registerOp],               [memoryOp, registerOp, immediateOp] ),
  _define(Mnemonic.and,   'and',    [memoryOp, registerOp],               [memoryOp, registerOp, immediateOp] ),
  _define(Mnemonic.brk,   'brk',    null,                                 null                                ),
  _define(Mnemonic.call,  'call',   [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.cmp,   'cmp',    [memoryOp, registerOp],               [memoryOp, registerOp, immediateOp] ),
  _define(Mnemonic.dec,   'dec',    [memoryOp, registerOp],               null                                ),
  _define(Mnemonic.div,   'div',    [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.hwi,   'hwi',    [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.hwq,   'hwq',    [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.inc,   'inc',    [memoryOp, registerOp],               null                                ),
  _define(Mnemonic.ja,    'ja',     [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.jc,    'jc',     [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.jg,    'jg',     [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.jge,   'jge',    [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.jl,    'jl',     [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.jle,   'jle',    [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.jmp,   'jmp',    [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.jna,   'jna',    [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.jnc,   'jnc',    [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.jno,   'jno',    [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.jns,   'jns',    [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.jnz,   'jnz',    [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.jo,    'jo',     [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.js,    'js',     [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.jz,    'jz',     [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.mov,   'mov',    [memoryOp, registerOp],               [memoryOp, registerOp, immediateOp] ),
  _define(Mnemonic.mul,   'mul',    [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.neg,   'neg',    [memoryOp, registerOp],               null                                ),
  _define(Mnemonic.nop,   'nop',    null,                                 null                                ),
  _define(Mnemonic.not,   'not',    [memoryOp, registerOp],               null                                ),
  _define(Mnemonic.or,    'or',     [memoryOp, registerOp],               [memoryOp, registerOp, immediateOp] ),
  _define(Mnemonic.pop,   'pop',    [memoryOp, registerOp],               null                                ),
  _define(Mnemonic.popf,  'popf',   null,                                 null                                ),
  _define(Mnemonic.push,  'push',   [memoryOp, registerOp, immediateOp],  null                                ),
  _define(Mnemonic.pushf, 'pushf',  null,                                 null                                ),
  _define(Mnemonic.rcl,   'rcl',    [memoryOp, registerOp],               [memoryOp, registerOp, immediateOp] ),
  _define(Mnemonic.rcr,   'rcr',    [memoryOp, registerOp],               [memoryOp, registerOp, immediateOp] ),
  _define(Mnemonic.ret,   'ret',    [immediateOp, noOp],                  null                                ),
  _define(Mnemonic.rol,   'rol',    [memoryOp, registerOp],               [memoryOp, registerOp, immediateOp] ),
  _define(Mnemonic.ror,   'ror',    [memoryOp, registerOp],               [memoryOp, registerOp, immediateOp] ),
  _define(Mnemonic.sal,   'sal',    [memoryOp, registerOp],               [memoryOp, registerOp, immediateOp] ),
  _define(Mnemonic.sar,   'sar',    [memoryOp, registerOp],               [memoryOp, registerOp, immediateOp] ),
  _define(Mnemonic.shl,   'shl',    [memoryOp, registerOp],               [memoryOp, registerOp, immediateOp] ),
  _define(Mnemonic.shr,   'shr',    [memoryOp, registerOp],               [memoryOp, registerOp, immediateOp] ),
  _define(Mnemonic.sub,   'sub',    [memoryOp, registerOp],               [memoryOp, registerOp, immediateOp] ),
  _define(Mnemonic.test,  'test',   [memoryOp, registerOp],               [memoryOp, registerOp, immediateOp] ),
  _define(Mnemonic.xchg,  'xchg',   [memoryOp, registerOp],               [memoryOp, registerOp] ),
  _define(Mnemonic.xor,   'xor',    [memoryOp, registerOp],               [memoryOp, registerOp, immediateOp] ),
];

/// A map of [Mnemonic] enum values to their respected [InstructionDefinition].
final Map<Mnemonic, InstructionDefinition> mnemonicsToInstructionDefs = _createMnemonicMap();

Map<Mnemonic, InstructionDefinition> _createMnemonicMap() {
  final Map<Mnemonic, InstructionDefinition> map = {};

  for (InstructionDefinition def in instructionDefinitions) {
    map[def.mnemonic] = def;
  }

  return map;
}

InstructionDefinition _define(
  Mnemonic mnemonic, 
  String mnemonicText,
  List<int> validOperand1Types,
  List<int> validOperand2Types
) {
  assert(mnemonic != null);
  assert(mnemonicText != null);

  return InstructionDefinition(
    mnemonic: mnemonic,
    mnemonicText: mnemonicText,
    operand1: InstructionOperandDefintion(validOperand1Types),
    operand2: InstructionOperandDefintion(validOperand2Types)
  );
}
