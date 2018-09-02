import 'dart:typed_data';

import 'disassembled_content.dart';

class DisassemblyLine {
  final int address;
  final Uint8List rawBytes;
  final DisassembledContent content;

  DisassemblyLine(this.address, this.content, this.rawBytes);
}