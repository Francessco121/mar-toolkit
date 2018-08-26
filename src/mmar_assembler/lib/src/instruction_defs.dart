import 'package:meta/meta.dart';

import 'writing/ir/mnemonic.dart';
import 'writing/ir/ir.dart' as ir;

const int memoryOp = 0x0001;
const int registerOp = 0x0010;
const int immediateOp = 0x0100;
const int noOp = 0x1000;

String operandTypeFlagToString(int type) {
  switch (type) {
    case immediateOp:
      return 'immediate';
    case memoryOp:
      return 'memory';
    case registerOp:
      return 'register';
    case noOp:
      return 'nothing';
  }

  throw ArgumentError.value(type, 'type');
}

int irOperandToTypeFlag(ir.InstructionOperand operand) {
  if (operand == null) {
    return noOp;
  }

  if (operand is ir.ImmediateOperand) {
    return immediateOp;
  } else if (operand is ir.MemoryInstructionOperand) {
    return memoryOp;
  } else if (operand is ir.RegisterOperand) {
    return registerOp;
  } else if (operand is ir.LabelOperand) {
    return immediateOp;
  }

  throw new ArgumentError.value(operand, 'operand');
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

@immutable
class InstructionDefinition {
  final Mnemonic mnemonic;
  final String mnemonicText;
  final InstructionOperandDefintion operand1;
  final InstructionOperandDefintion operand2;

  InstructionDefinition({
    @required this.mnemonic,
    @required this.mnemonicText,
    @required this.operand1,
    @required this.operand2
  });
}

@immutable
class InstructionOperandDefintion {
  final int _validFlags;
  final List<int> _validTypes;

  InstructionOperandDefintion(List<int> validTypes)
    : _validTypes = validTypes,
      _validFlags = _createOperandFlag(validTypes);

  /// Returns whether the given [typeFlag] is a valid operand type
  /// of this definition.
  bool isFlagValid(int typeFlag) {
    return typeFlag & _validFlags != 0            // Flag has type
      || (typeFlag == noOp && _validFlags == 0);  // or type is a noop and flags are nothing
  }

  /// Returns a string with a list of valid operand types
  /// for this definition.
  /// 
  /// #### Examples:
  /// - "nothing"
  /// - "register"
  /// - "memory or register"
  /// - "memory, immediate, or register"
  String createHumanReadableTypeList() {
    if (_validTypes == null || _validTypes.length == 0) {
      // No types
      return operandTypeFlagToString(noOp);
    } else if (_validTypes.length == 1) {
      // One type
      return operandTypeFlagToString(_validTypes[0]);
    } else if (_validTypes.length == 2) {
      // Two types
      return operandTypeFlagToString(_validTypes[0])
        + ' or '
        + operandTypeFlagToString(_validTypes[1]);
    } else {
      // Three or more types
      final buffer = new StringBuffer();

      for (int i = 0; i < _validTypes.length; i++) {
        if (i > 0) {
          buffer.write(', ');
        }

        if (i == _validTypes.length - 1) {
          buffer.write('or ');
        }

        buffer.write(operandTypeFlagToString(_validTypes[i]));
      }

      return buffer.toString();
    }
  }

  static int _createOperandFlag(List<int> validTypes) {
    // TODO: Instead of returning 0 for no types, should this instead
    //       return [noOp]? This may simplify validation.

    if (validTypes == null) {
      return 0;
    } else {
      int flag = 0;

      for (int operand in validTypes) {
        flag |= operand;
      }

      return flag;
    }
  }
}