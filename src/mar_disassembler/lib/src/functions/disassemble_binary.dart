import 'dart:typed_data';

import '../disassembly/disassembly.dart';
import '../source.dart';
import 'read_binary.dart';
import 'reinterpret_disassembly.dart';
import 'write_disassembly.dart';

String disassembleBinary(Source source, Uint8List data) {
  // Read the binary
  final List<DisassemblyLine> lines = readBinary(source, data);

  // Reinterpret and annotate the disassembly
  reinterpretDisassembly(lines);

  // Write the disassembly to a string
  return writeDisassembly(source, lines);
}
