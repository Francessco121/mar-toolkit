import 'package:mar/mar.dart';

import '../disassembly/disassembly.dart';

void labelJumps(List<DisassemblyLine> lines) {
  int nextLabelIndex = 0;

  for (int i = 0; i < lines.length; i++) {
    final DisassemblyLine line = lines[i];
    final DisassembledContent content = line.content;

    if (content is DisassembledInstruction) {
      if (_isJumpMnemonic(content.mnemonic) && content.operand1 != null) {
        final InstructionOperand operand = content.operand1;

        if (operand is ImmediateOperand) {
          final int address = operand.value;
          final int addressIndex = _getAddressIndex(lines, address);

          if (addressIndex != null) {
            final String label = 'label_${nextLabelIndex++}';

            // Replace immediate operand with a label
            lines[i] = DisassemblyLine(
              line.address,
              DisassembledInstruction(content.mnemonic,
                operand1: LabelOperand(label),
                operand2: content.operand2
              ),
              line.rawBytes
            );
            
            // Insert a label at the address
            lines.insert(addressIndex, DisassemblyLine(
              null, 
              DisassembledLabel(label),
              null
            ));

            // Skip an index if the inserted line was before
            // the current line
            if (addressIndex <= i) {
              i++;
            }
          }
        }
      }
    }
  }
}

int _getAddressIndex(List<DisassemblyLine> lines, int address) {
  int lastAddress = null;

  // TODO: Implement faster search algorithm
  for (int i = 0; i < lines.length; i++) {
    final DisassemblyLine line = lines[i];

    if (line.address == null) {
      continue;
    }

    if (line.address == address) {
      return i;
    }

    if (lastAddress != null 
      && lastAddress < address 
      && line.address > address
    ) {
      // Already passed the address, so no line corresponds to it
      break;
    }

    lastAddress = line.address;
  }

  // ignore: avoid_returning_null
  return null;
}

bool _isJumpMnemonic(Mnemonic mnemonic) {
  return mnemonic == Mnemonic.ja
    || mnemonic == Mnemonic.jc
    || mnemonic == Mnemonic.jg
    || mnemonic == Mnemonic.jge
    || mnemonic == Mnemonic.jl
    || mnemonic == Mnemonic.jle
    || mnemonic == Mnemonic.jmp
    || mnemonic == Mnemonic.jna
    || mnemonic == Mnemonic.jnc
    || mnemonic == Mnemonic.jno
    || mnemonic == Mnemonic.jns
    || mnemonic == Mnemonic.jnz
    || mnemonic == Mnemonic.jo
    || mnemonic == Mnemonic.js
    || mnemonic == Mnemonic.jz;
}