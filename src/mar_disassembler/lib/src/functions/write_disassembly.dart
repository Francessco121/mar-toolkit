import 'dart:typed_data';

import 'package:charcode/charcode.dart';
import 'package:mar/mar.dart';

import '../disassembly/disassembly.dart';

const int _contentPadding = 12;
const int _hexdumpPadding = 40;
const int _textHexdumpPadding = 56;

String writeDisassembly(List<DisassemblyLine> lines) {
  final buffer = new StringBuffer();
  final visitor = new _LineVisitor(buffer);

  for (DisassemblyLine line in lines) {
    int column = 0;

    // Write the address if it exists
    if (line.address != null) {
      buffer.write('_');
      column++;

      final String addressString = _integerAsString(line.address);
      buffer.write(addressString);
      column += addressString.length;

      buffer.write(':');
      column++;
    }

    column += _pad(buffer, _contentPadding - column);

    // Write the content
    final int lastBufferLength = buffer.length;
    line.content.accept(visitor);

    // Use the change in buffer length to determine what column we are on
    // (the visitor will never add a newline)
    column += buffer.length - lastBufferLength;

    // Write the hexdump if the line contains raw bytes
    if (line.rawBytes != null) {
      column += _pad(buffer, _hexdumpPadding - column);

      final String binaryDump = _getBinaryHexdump(line.rawBytes);
      buffer.write('; $binaryDump');
      column += binaryDump.length;

      column += _pad(buffer, _textHexdumpPadding - column);

      final String textDump = _getTextHexdump(line.rawBytes);
      buffer.write(textDump);
      column += textDump.length;
    }

    buffer.writeln();
  }

  return buffer.toString();
}

class _LineVisitor implements DisassembledContentVisitor {
  int currentColumn = 0;

  final StringBuffer _buffer;

  _LineVisitor(this._buffer)
    : assert(_buffer != null);

  @override
  void visitComment(DisassembledComment comment) {
    _buffer.write('; ${comment.comment}');
  }

  @override
  void visitDwDirective(DisassembledDwDirective dwDirective) {
    _buffer.write('DW ');

    bool first = true;
    for (DwOperand operand in dwDirective.operands) {
      if (!first) {
        _buffer.write(', ');
      }

      if (operand.value is int) {
        _buffer.write(_integerAsString(operand.value as int));
      } else {
        _writeString(operand.value as String);
      }

      if (operand.duplicate != null) {
        _buffer.write(' DUP(');
        _buffer.write(_integerAsString(operand.duplicate));
        _buffer.write(')');
      }

      first = false;
    }
  }

  @override
  void visitInstruction(DisassembledInstruction instruction) {
    _buffer.write(mnemonicToString(instruction.mnemonic).toUpperCase());

    if (instruction.operand1 != null) {
      _buffer.write(' ');
      _writeInstructionOperand(instruction.operand1);

      if (instruction.operand2 != null) {
        _buffer.write(', ');
        _writeInstructionOperand(instruction.operand2);
      }
    }
  }

  @override
  void visitLabel(DisassembledLabel label) {
    _buffer.write(label.label);
    _buffer.write(':');
  }

  void _writeInstructionOperand(InstructionOperand operand) {
    if (operand is ImmediateOperand) {
      // Immediate
      _buffer.write(_integerAsString(operand.value));
    } else if (operand is LabelOperand) {
      // Label
      final LabelOperand label = operand;

      _buffer.write(label.labelIdentifier);
    } else if (operand is ConstOperand) {
      // Constant reference
      _buffer.write(operand.constIdentifier);
    } else if (operand is RegisterOperand) {
      // Register
      _buffer.write(registerToString(operand.register).toUpperCase());
    } else if (operand is MemoryInstructionOperand) {
      // Memory
      _buffer.write('[');

      _writeMemoryOperand(operand.value);

      if (operand.displacement != null) {
        _buffer.write(' ');
        _buffer.write(displacementOperatorToString(operand.displacement.$operator));
        _buffer.write(' ');

        _writeDisplacementOperand(operand.displacement.value);
      }

      _buffer.write(']');
    } else {
      // Should never happen
      throw ArgumentError.value(operand, 'operand');
    }
  }

  void _writeMemoryOperand(MemoryOperand operand) {
    if (operand is ImmediateOperand) {
      // Immediate
      _buffer.write(_integerAsString(operand.value));
    } else if (operand is LabelOperand) {
      // Label
      _buffer.write(operand.labelIdentifier);
    } else if (operand is ConstOperand) {
      // Constant reference
      _buffer.write(operand.constIdentifier);
    } else if (operand is RegisterOperand) {
      // Register
      _buffer.write(registerToString(operand.register).toUpperCase());
    } else {
      // Should never happen
      throw ArgumentError.value(operand, 'operand');
    }
  }

  void _writeDisplacementOperand(DisplacementOperand operand) {
    if (operand is ImmediateOperand) {
      // Immediate
      _buffer.write(_integerAsString(operand.value));
    } else if (operand is LabelOperand) {
      // Label
      _buffer.write(operand.labelIdentifier);
    } else if (operand is ConstOperand) {
      // Constant reference
      _buffer.write(operand.constIdentifier);
    } else {
      // Should never happen
      throw ArgumentError.value(operand, 'operand');
    }
  }

  void _writeString(String string) {
    _buffer.write('"');

    for (int i = 0; i < string.length; i++) {
      int char = string.codeUnitAt(i);

      switch (char) {
        case $tab:
          _buffer.write(r'\t');
          break;
        case $bs:
          _buffer.write(r'\b');
          break;
        case $lf:
          _buffer.write(r'\n');
          break;
        case $cr:
          _buffer.write(r'\r');
          break;
        case $ff:
          _buffer.write(r'\f');
          break;
        case $quote:
          _buffer.write(r'\"');
          break;
        case $backslash:
          _buffer.write(r'\\');
          break;
        default:
          if (char < $space) {
            // Encode invisible characters as unicode escape sequences
            _buffer.write(_escapeAsUnicode(char));
          } else {
            _buffer.writeCharCode(char);
          }
          break;
      }
    }

    _buffer.write('"');
  }

  String _escapeAsUnicode(int char) {
    final String string = char.toRadixString(16);

    if (string.length < 4) {
      // MAR strings require unicode escape sequences to have exactly 4 digits
      final buffer = new StringBuffer(r'\u');

      for (int i = string.length; i < 4; i++) {
        buffer.write('0');
      }

      buffer.write(string);

      return buffer.toString();
    } else {
      return r'\u' + string;
    }
  }
}

String _getBinaryHexdump(Uint8List data) {
  final buffer = new StringBuffer();
  
  for (final byte in data) {
    if (buffer.length > 0) {
      buffer.write(' ');
    }

    final String radix = byte.toRadixString(16);
    if (radix.length < 2) {
      buffer.write('0');
    }

    buffer.write(radix);
  }

  return buffer.toString();
}

String _getTextHexdump(Uint8List data) {
  final buffer = new StringBuffer();
  
  for (final byte in data) {
    if (byte >= $space && byte < 255) {
      buffer.writeCharCode(byte);
    } else {
      buffer.write('.');
    }
  }

  return buffer.toString();
}

int _pad(StringBuffer buffer, int padding) {
  for (int i = 0; i < padding; i++) {
    buffer.write(' ');
  }

  return padding;
}

String _integerAsString(int value) {
  final String string = value.toRadixString(16);

  if (string.length < 4) {
    final buffer = new StringBuffer('0x');

    for (int i = string.length; i < 4; i++) {
      buffer.write('0');
    }

    buffer.write(string);

    return buffer.toString();
  } else {
    return '0x$string';
  }
}
