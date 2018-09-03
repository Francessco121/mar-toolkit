import 'package:charcode/charcode.dart';

import '../ir/ir.dart';
import '../mnemonic.dart';
import '../register.dart';

/// Assembles a list of MAR source [lines] into textual MAR source code.
String assembleText(List<Line> lines) {
  assert(lines != null);

  final buffer = new StringBuffer();
  final visitor = new _TextWriterLineVisitor(buffer);

  for (Line line in lines) {
    line.accept(visitor);
  }

  return buffer.toString();
}

class _TextWriterLineVisitor implements LineVisitor {
  bool _inSection = false;
  int _indents = 0;

  final StringBuffer _buffer;

  _TextWriterLineVisitor(this._buffer)
    : assert(_buffer != null);

  @override
  void visitComment(Comment comment) {
    _writeIndentation();

    _buffer.writeln('; ${comment.comment}');
  }

  @override
  void visitConstant(Constant constant) {
    _writeIndentation();

    _buffer.write(constant.identifier);
    _buffer.write(' EQU ');
    _buffer.write(_integerAsString(constant.value));
    _writeCommentIfExists(constant);
    _buffer.writeln();
  }

  @override
  void visitDwDirective(DwDirective dwDirective) {
    _writeIndentation();
    _writeLabelIfExists(dwDirective);

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

    _writeCommentIfExists(dwDirective);
    _buffer.writeln();
  }

  @override
  void visitInstruction(Instruction instruction) {
    _writeIndentation();
    _writeLabelIfExists(instruction);

    _buffer.write(mnemonicToString(instruction.mnemonic));

    if (instruction.operand1 != null) {
      _buffer.write(' ');
      _writeInstructionOperand(instruction.operand1);

      if (instruction.operand2 != null) {
        _buffer.write(', ');
        _writeInstructionOperand(instruction.operand2);
      }
    }

    _writeCommentIfExists(instruction);
    _buffer.writeln();
  }

  @override
  void visitLabel(Label label) {
    _buffer.writeln();

    if (_inSection) {
      _indents = 1;
      _writeIndentation();
      _indents = 2;
    } else {
      _indents = 1;
    }

    _buffer.write(label.label);
    _buffer.write(':');
    _writeCommentIfExists(label);
    _buffer.writeln();
  }

  @override
  void visitOrgDirective(OrgDirective orgDirective) {
    _buffer.write('ORG ');
    _buffer.write(_integerAsString(orgDirective.value));
    _writeCommentIfExists(orgDirective);
    _buffer.writeln();
    _buffer.writeln();
  }

  @override
  void visitSection(Section section) {
    _inSection = true;
    _indents = 1;

    _buffer.writeln();
    _buffer.write('.${section.identifier}');
    _writeCommentIfExists(section);
    _buffer.writeln();
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

  void _writeLabelIfExists(Labelable labelable) {
    if (labelable.label != null) {
      _buffer.write(labelable.label);
      _buffer.write(': ');
    }
  }

  void _writeCommentIfExists(Line line) {
    if (line.comment != null && line.comment.trim().isNotEmpty) {
      _buffer.write(' ; ${line.comment}');
    }
  }

  void _writeIndentation() {
    for (int i = 0; i < _indents; i++) {
      _buffer.write('  ');
    }
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

  String _integerAsString(int value) {
    // AND with 0xFFFF to cut-off bits above 16-bits.
    // Effectively 'wraps' the value.
    return '0x' + (value & 0xFFFF).toRadixString(16);
  }
}