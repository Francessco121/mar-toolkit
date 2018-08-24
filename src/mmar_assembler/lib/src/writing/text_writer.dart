import 'ir/ir.dart' as ir;

class TextWriter {
  final List<ir.Line> _lines;

  TextWriter(this._lines)
    : assert(_lines != null);

  String write() {
    final buffer = new StringBuffer();
    final visitor = new _TextWriterLineVisitor(buffer);

    for (ir.Line line in _lines) {
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
    _buffer.write(' equ ');
    _buffer.write(_integerAsString(constant.value));
    _writeCommentIfExists(constant);
    _buffer.writeln();
  }

  @override
  void visitDwDirective(ir.DwDirective dwDirective) {
    // TODO: implement visitDwDirective
  }

  @override
  void visitInstruction(ir.Instruction instruction) {
    _writeLabelIfExists(instruction);

    

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
    _buffer.write('org ');
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