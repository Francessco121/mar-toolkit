import 'dart:typed_data';

import 'package:mar/mar.dart';
import 'package:meta/meta.dart';

import '../disassembly/disassembly.dart';
import '../selector_type.dart';

List<DisassemblyLine> readBinary(Uint8List data) {
  final reader = new _BinaryReader(data);
  reader.read();

  return reader.lines;
}

class _BinaryReader {
  final List<DisassemblyLine> lines = [];

  static const int _$6bitMask = 0x3F; // 0x3F = 0b11_1111
  static const int _$5bitMask = 0x1F; // 0x1F = 0b1_1111

  static const int _memoryImm16 = 0x1E; // 0x1E = 0b1_1110
  static const int _immediate16 = 0x1F; // 0x1F = 0b1_1111

  int _position = 0;
  int _current;

  final Uint8List _data;

  _BinaryReader(this._data)
    : assert(_data != null);

  void read() {
    // Prep
    _current = _readWord();

    while (!_isAtEnd()) {
      _readInstruction();
    }
  }

  void _readInstruction() {
    final int address = (_position ~/ 2) - 1;

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

    if (instructionDef != null 
      && sourceType != SelectorType.unknown 
      && destinationType != SelectorType.unknown
    ) {
      // Output an instruction if everything was decoded successfully
      final int wordLength = _getInstructionWordLength(destinationType, sourceType);

      InstructionOperand operand1;
      InstructionOperand operand2;

      if (destinationType != SelectorType.none) {
        // Note: Source is encoded first, but technically the second operand
        operand2 = _getInstructionOperand(sourceType, sourceSelector);
        operand1 = _getInstructionOperand(destinationType, destinationSelector);
      } else {
        operand1 = _getInstructionOperand(sourceType, sourceSelector);
      }

      _addInstruction(
        address: address, 
        wordLength: wordLength, 
        mnemonic: instructionDef.mnemonic,
        operand1: operand1,
        operand2: operand2
      );
    } else {
      // Output a DW line with just the one word if we could not decode an instruction.
      // Just assume it's data for now instead.
      lines.add(
        DisassemblyLine(
          address,
          DisassembledDwDirective([DwOperand(instructionWord)]),
          _getRawData(address, 1)
        )
      );
    }
  }

  InstructionOperand _getInstructionOperand(SelectorType type, int rawSelector) {
    if (type == SelectorType.none) {
      return null;
    }

    if (type == SelectorType.immediate16) {
      final int operandWord = _advance();

      return ImmediateOperand(operandWord);
    } else if (type == SelectorType.memoryImmediate16) {
      final int operandWord = _advance();

      return MemoryInstructionOperand(ImmediateOperand(operandWord));
    } else if (type == SelectorType.register16) {
      final int registerIndex = rawSelector;
      final Register register = indexesToRegisters[registerIndex];

      return RegisterOperand(register);
    } else if (type == SelectorType.memoryRegister16) {
      final int registerIndex = rawSelector - 0x8;
      final Register register = indexesToRegisters[registerIndex];

      return MemoryInstructionOperand(RegisterOperand(register));
    } else if (type == SelectorType.memoryRegisterDisplaced16) {
      final int operandWord = _advance();
      final int registerIndex = rawSelector - 0x10;
      final Register register = indexesToRegisters[registerIndex];

      return MemoryInstructionOperand(RegisterOperand(register),
        displacement: Displacement(DisplacementOperator.plus, ImmediateOperand(operandWord))
      );
    } else {
      throw new ArgumentError.value(type, 'type');
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
        return SelectorType.memoryRegisterDisplaced16;
      }
    }

    return SelectorType.unknown;
  }

  void _addInstruction({
    @required int address, 
    @required int wordLength, 
    @required Mnemonic mnemonic,
    @required InstructionOperand operand1,
    @required InstructionOperand operand2
  }) {
    lines.add(
      DisassemblyLine(
        address, 
        DisassembledInstruction(mnemonic,
          operand1: operand1,
          operand2: operand2
        ),
        _getRawData(address, wordLength)
      )
    );
  }

  int _getInstructionWordLength(SelectorType selector1, SelectorType selector2) {
    int length = 1;

    if (_selectorHasOperandWord(selector1)) {
      length++;
    }

    if (_selectorHasOperandWord(selector2)) {
      length++;
    }

    return length;
  }

  bool _selectorHasOperandWord(SelectorType selector) {
    return selector == SelectorType.immediate16
      || selector == SelectorType.memoryImmediate16
      || selector == SelectorType.memoryRegisterDisplaced16;
  }

  Uint8List _getRawData(int address, int wordLength) {
    final int position = address * 2;
    final int byteLength = wordLength * 2;

    return Uint8List.view(_data.buffer, position, byteLength);
  }

  int _advance() {
    int word = _current;
    _current = _readWord();

    return word;
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
