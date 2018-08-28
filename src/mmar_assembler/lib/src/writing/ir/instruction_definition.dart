import 'package:meta/meta.dart';

import 'mnemonic.dart';
import 'operand_type_flags.dart';

@immutable
class InstructionDefinition {
  final Mnemonic mnemonic;
  final String mnemonicText;
  final InstructionOperandDefintion operand1;
  final InstructionOperandDefintion operand2;

  const InstructionDefinition({
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
    if (_validTypes == null || _validTypes.isEmpty) {
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