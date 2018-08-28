import 'ir/ir.dart' as ir;

class TextWriter {
  String write(List<ir.Line> lines) {
    assert(lines != null);

    final buffer = new StringBuffer();
    final visitor = new _TextWriterLineVisitor(buffer);

    for (ir.Line line in lines) {
      line.accept(visitor);
    }

    return buffer.toString();
  }
}

class _TextWriterLineVisitor implements ir.LineVisitor {
  final StringBuffer _buffer;

  // TODO: indentation
  // TODO: debug vs release modes

  _TextWriterLineVisitor(this._buffer)
    : assert(_buffer != null);

  @override
  void visitComment(ir.Comment comment) {
    _buffer.writeln('; ${comment.comment}');
  }

  @override
  void visitConstant(ir.Constant constant) {
    _buffer.write(constant.identifier);
    _buffer.write(' EQU ');
    _buffer.write(_integerAsString(constant.value));
    _writeCommentIfExists(constant);
    _buffer.writeln();
  }

  @override
  void visitDwDirective(ir.DwDirective dwDirective) {
    _writeLabelIfExists(dwDirective);

    _buffer.write('DW ');

    bool first = true;
    for (ir.DwOperand operand in dwDirective.operands) {
      if (!first) {
        _buffer.write(', ');
      }

      if (operand.value is int) {
        _buffer.write(_integerAsString(operand.value as int));
      } else {
        _buffer.write('"${operand.value}"');
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
  void visitInstruction(ir.Instruction instruction) {
    _writeLabelIfExists(instruction);

    _buffer.write(ir.mnemonicToString(instruction.mnemonic).toUpperCase());

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
  void visitLabel(ir.Label label) {
    _buffer.write(label.label);
    _buffer.write(':');
    _buffer.writeln();
  }

  @override
  void visitOrgDirective(ir.OrgDirective orgDirective) {
    _buffer.write('ORG ');
    _buffer.write(_integerAsString(orgDirective.value));
    _writeCommentIfExists(orgDirective);
    _buffer.writeln();
  }

  @override
  void visitSection(ir.Section section) {
    _buffer.write('.${section.identifier}');
    _writeCommentIfExists(section);
    _buffer.writeln();
  }

  void _writeInstructionOperand(ir.InstructionOperand operand) {
    if (operand is ir.ImmediateOperand) {
      // Immediate
      final ir.ImmediateOperand immediate = operand;

      _buffer.write(_integerAsString(immediate.value));
    } else if (operand is ir.LabelOperand) {
      // Label
      final ir.LabelOperand label = operand;

      _buffer.write(label.labelIdentifier);
    } else if (operand is ir.ConstOperand) {
      // Constant reference
      final ir.ConstOperand constant = operand;

      _buffer.write(constant.constIdentifier);
    } else if (operand is ir.RegisterOperand) {
      // Register
      final ir.RegisterOperand register = operand;

      _buffer.write(ir.registerToString(register.register).toUpperCase());
    } else if (operand is ir.MemoryInstructionOperand) {
      // Memory
      final ir.MemoryInstructionOperand memory = operand;

      _buffer.write('[');

      _writeMemoryOperand(memory.value);

      if (memory.displacement != null) {
        _buffer.write(' ');
        _buffer.write(ir.displacementOperatorToString(memory.displacement.$operator));
        _buffer.write(' ');

        _writeDisplacementOperand(memory.displacement.value);
      }

      _buffer.write(']');
    } else {
      // Should never happen
      throw ArgumentError.value(operand, 'operand');
    }
  }

  void _writeMemoryOperand(ir.MemoryOperand operand) {
    if (operand is ir.ImmediateOperand) {
      // Immediate
      final ir.ImmediateOperand immediate = operand;

      _buffer.write(_integerAsString(immediate.value));
    } else if (operand is ir.LabelOperand) {
      // Label
      final ir.LabelOperand label = operand;

      _buffer.write(label.labelIdentifier);
    } else if (operand is ir.ConstOperand) {
      // Constant reference
      final ir.ConstOperand constant = operand;

      _buffer.write(constant.constIdentifier);
    } else if (operand is ir.RegisterOperand) {
      // Register
      final ir.RegisterOperand register = operand;

      _buffer.write(ir.registerToString(register.register).toUpperCase());
    } else {
      // Should never happen
      throw ArgumentError.value(operand, 'operand');
    }
  }

  void _writeDisplacementOperand(ir.DisplacementOperand operand) {
    if (operand is ir.ImmediateOperand) {
      // Immediate
      final ir.ImmediateOperand immediate = operand;

      _buffer.write(_integerAsString(immediate.value));
    } else if (operand is ir.LabelOperand) {
      // Label
      final ir.LabelOperand label = operand;

      _buffer.write(label.labelIdentifier);
    } else if (operand is ir.ConstOperand) {
      // Constant reference
      final ir.ConstOperand constant = operand;

      _buffer.write(constant.constIdentifier);
    } else {
      // Should never happen
      throw ArgumentError.value(operand, 'operand');
    }
  }

  void _writeLabelIfExists(ir.Labelable labelable) {
    if (labelable.label != null) {
      _buffer.write(labelable.label);
      _buffer.write(': ');
    }
  }

  void _writeCommentIfExists(ir.Line line) {
    if (line.comment != null && line.comment.trim().isNotEmpty) {
      _buffer.write(' ; ${line.comment}');
    }
  }

  String _integerAsString(int value) {
    // TODO: Support other modes
    return '0x' + value.toRadixString(16);
  }
}