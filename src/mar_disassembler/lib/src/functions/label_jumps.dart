import 'package:mar/mar.dart';

import '../disassembly/disassembly.dart';

void labelJumps(List<DisassemblyLine> lines) {
  int nextLabelIndex = 0;

  for (int i = 0; i < lines.length; i++) {
    final DisassemblyLine line = lines[i];
    final DisassembledContent content = line.content;

    // Check if the current line is a jump with an immediate operand
    if (content is DisassembledInstruction 
      && _isJumpMnemonic(content.mnemonic)
      && content.operand1 is ImmediateOperand
    ) {
      final ImmediateOperand operand = content.operand1;

      final int address = operand.value;
      final int addressIndex = _getAddressIndex(lines, address);

      // Ensure the jump-to address is in the binary
      if (addressIndex != null) {
        String label;
        bool labelReused = false;

        final DisassembledContent targetContent = lines[addressIndex].content;
        if (targetContent is DisassembledLabel) {
          // Re-use label
          label = targetContent.label;
          labelReused = true;
        } else {
          label = 'label_${nextLabelIndex++}';
        }

        // Replace immediate operand with a label
        lines[i] = DisassemblyLine(
          line.address,
          DisassembledInstruction(content.mnemonic,
            operand1: LabelOperand(label),
            operand2: content.operand2
          ),
          line.rawBytes
        );
        
        if (!labelReused) {
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

int _getAddressIndex(List<DisassemblyLine> lines, int address) {
  int lastAddress = null;
  DisassemblyLine lastLine = null;

  // TODO: Implement faster search algorithm
  for (int i = 0; i < lines.length; i++) {
    final DisassemblyLine line = lines[i];

    if (line.address == address) {
      if (lastLine.content is DisassembledLabel) {
        // Re-use label
        return i - 1;
      } else {
        return i;
      }
    }

    if (lastAddress != null
      && line.address != null
      && lastAddress < address 
      && line.address > address
    ) {
      // Already passed the address, so no line corresponds to it
      break;
    }

    lastAddress = line.address;
    lastLine = line;
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