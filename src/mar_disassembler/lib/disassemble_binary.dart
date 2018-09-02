import 'dart:typed_data';

import 'package:mar/mar.dart';

import 'src/selector_type.dart';

String disassembleBinary(Uint8List data) {
  final buffer = new StringBuffer();
  final reader = new _BinaryReader(buffer, data);
  
  reader.read();

  return buffer.toString();
}

class _BinaryReader {
  static const int _$6bitMask = 0x3F; // 0x3F = 0b11_1111
  static const int _$5bitMask = 0x1F; // 0x1F = 0b1_1111

  static const int _memoryImm16 = 0x1E; // 0x1E = 0b1_1110
  static const int _immediate16 = 0x1F ; // 0x1F = 0b1_1111

  int _position = 0;
  int _current;

  final StringBuffer _buffer;
  final Uint8List _data;

  _BinaryReader(this._buffer, this._data)
    : assert(_buffer != null),
      assert(_data != null);

  void read() {
    // Prep
    _current = _readWord();

    while (!_isAtEnd()) {
      _readInstruction();
    }
  }

  void _readInstruction() {
    final int instructionWord = _advance();

    // Extract the opcode from the lower 6 bits
    final int opcode = instructionWord & _$6bitMask;

    // Extract the operand selectors

    // Destination = bits 6-10
    final int destinationSelector = (instructionWord >> 6) & _$5bitMask;

    // Source = bits 11-15
    final int sourceSelector = (instructionWord >> 11) & _$5bitMask;

    // Get the types of the operand selectors
    final SelectorType destinationType = _getSelectorType(destinationSelector);
    final SelectorType sourceType = _getSelectorType(sourceSelector);

    // Get the instruction definition
    final InstructionDefinition instructionDef = opcodesToInstructionDefs[opcode];

    // Write the mnemonic
    if (instructionDef != null) {
      _buffer.write(instructionDef.mnemonicText);
      _buffer.write(' ');
    } else {
      _buffer.write('M??? ');
    }

    // Write the operands
    if (destinationType != SelectorType.none) {
      _writeInstructionOperand(destinationType, destinationSelector);
      _buffer.write(', ');
      _writeInstructionOperand(sourceType, sourceSelector);
    } else {
      _writeInstructionOperand(sourceType, sourceSelector);
    }

    _buffer.writeln();
  }

  void _writeInstructionOperand(SelectorType type, int rawSelector) {
    if (type == SelectorType.none) {
      return;
    }

    if (type == SelectorType.unknown) {
      _buffer.write('O???');
      return;
    }

    if (type == SelectorType.immediate16) {
      final int operandWord = _advance();

      _buffer.write(_integerAsString(operandWord));
    } else if (type == SelectorType.memoryImmediate16) {
      final int operandWord = _advance();

      _buffer.write('[');
      _buffer.write(_integerAsString(operandWord));
      _buffer.write(']');
    } else if (type == SelectorType.register16) {
      final int enumIndex = rawSelector - 1;

      _buffer.write(_registerEnumIndexToString(enumIndex));
    } else if (type == SelectorType.memoryRegister16) {
      final int enumIndex = (rawSelector - 0x8) - 1;

      _buffer.write('[');
      _buffer.write(_registerEnumIndexToString(enumIndex));
      _buffer.write(']');
    } else if (type == SelectorType.memoryRegisterDisplaced16) {
      final int operandWord = _advance();
      final int enumIndex = (rawSelector - 0x8) - 1;

      _buffer.write('[');
      _buffer.write(_registerEnumIndexToString(enumIndex));
      _buffer.write(' + ');
      _buffer.write(_integerAsString(operandWord));
      _buffer.write(']');
    } else {
      throw new ArgumentError.value(type, 'type');
    }
  }

  String _registerEnumIndexToString(int enumIndex) {
    if (enumIndex >= 0 && enumIndex < Register.values.length) {
      final Register register = Register.values[enumIndex];
      final String registerText = registerToString(register);

      return registerText.toUpperCase();
    } else {
      return 'R?';
    }
  }

  /// Converts a raw 5-bit selector into a [SelectorType].
  /// 
  /// This does not extract any additional data encoded in the selector,
  /// it just determines the type. 
  SelectorType _getSelectorType(int selector) {
    if (selector == 0) {
      return SelectorType.none;
    } else if (selector == _memoryImm16) {
      return SelectorType.memoryImmediate16;
    } else if (selector == _immediate16) {
      return SelectorType.immediate16;
    } else if (selector >= 0x1 && selector <= 0x8) {
      return SelectorType.register16;
    } else {
      final int regOffset = selector - 0x8;

      if (regOffset >= 0x1 && regOffset <= 0x8) {
        return SelectorType.memoryRegister16;
      }

      final int regDispOffset = selector - 0x10;

      if (regDispOffset >= 0x1 && regDispOffset <= 0x8) {
        return SelectorType.memoryRegister16;
      }
    }

    return SelectorType.unknown;
  }

  String _integerAsString(int value) {
    // AND with 0xFFFF to cut-off bits above 16-bits.
    // Effectively 'wraps' the value.
    return '0x' + (value & 0xFFFF).toRadixString(16);
  }

  int _advance() {
    int word = _current;
    _current = _readWord();

    return word;
  }

  int _peek() {
    return _current;
  }

  int _readWord() {
    if (_position >= _data.length) {
      // ignore: avoid_returning_null
      return null;
    }
    
    int upper = _readByte();
    int lower = _readByte();

    int word = 0;

    if (lower != null) {
      word |= lower;
      word |= (upper << 8);
    } else {
      word |= (upper << 8);
    }

    return word;
  }
  
  int _readByte() {
    if (_position < _data.length) {
      return _data[_position++];
    } else {
      // ignore: avoid_returning_null
      return null;
    }
  }

  bool _isAtEnd() {
    return  _current == null;
  }
}
