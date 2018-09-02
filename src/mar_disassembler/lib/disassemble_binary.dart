import 'dart:typed_data';

import 'src/disassembly/disassembly.dart';
import 'src/functions/read_binary.dart';
import 'src/functions/write_disassembly.dart';

String disassembleBinary(Uri uri, Uint8List data) {
  // Read the binary
  final List<DisassemblyLine> lines = readBinary(data);

  // Insert a header comment with the original file URI
  lines.insert(0, DisassemblyLine(null, DisassembledComment('Disassembly of $uri'), null));

  // Write the disassembly to a string
  return writeDisassembly(lines);
}
