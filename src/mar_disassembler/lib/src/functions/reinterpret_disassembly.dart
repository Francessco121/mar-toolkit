import 'dart:typed_data';

import 'package:mar/mar.dart';

import '../disassembly/disassembly.dart';

void reinterpretDisassembly(List<DisassemblyLine> lines) {
  final reinterpreter = new _Reinterpreter(lines);
  reinterpreter.reinterpret();
}

class _Reinterpreter {
  int _nextJumpLabelIndex = 0;
  int _nextCallLabelIndex = 0;
  int _nextDataLabelIndex = 0;

  int _i = 0;
  List<DisassemblyLine> _lines;
  
  _Reinterpreter(this._lines)
    : assert(_lines != null);

  void reinterpret() {
    // Pass #1: Annotate references with labels
    for (_i = 0; _i < _lines.length; _i++) {
      // Label jumps and calls
      _tryLabelJumpOrCall();

      // Label memory references
      _tryLabelOperandMemory(1);
      _tryLabelOperandMemory(2);
    }

    // Pass #2: Re-interpret data as DW directives
    //
    // 99% of the time, words after a line that was labled
    // as data is actually data. A lot of this gets mistaken
    // for valid instructions however, so we overwrite them here.
    bool replacing = false;

    for (_i = 0; _i < _lines.length; _i++) {
      final DisassemblyLine line = _lines[_i];
      final DisassembledContent content = line.content;

      if (content is DisassembledLabel) {
        if (content.label.startsWith('data_')) {
          replacing = true;
        } else {
          // Replace up to the next non-data label
          replacing = false;
        }
      }

      if (replacing) {
        _reinterpretAsDw();
      }
    }
  }

  void _tryLabelJumpOrCall() {
    final DisassemblyLine line = _lines[_i];
    final DisassembledContent content = line.content;

    // Ensure line is an instruction
    if (line.content is! DisassembledInstruction) {
      return;
    }

    final DisassembledInstruction instruction = content;

    // Ensure instruction is for a jump/call to an immediate address
    if (!_isJumpOrCallMnemonic(instruction.mnemonic)) {
      return;
    }

    if (instruction.operand1 is! ImmediateOperand) {
      return;
    }

    final ImmediateOperand operand = instruction.operand1;

    // Get the target address
    final int address = operand.value;
    final int addressIndex = _getAddressIndex(address);

    // Ensure the target address is in the binary
    if (addressIndex == null) {
      return;
    }

    // Label the target
    String label;
    bool labelReused = false;

    final DisassembledContent targetContent = _lines[addressIndex].content;
    if (targetContent is DisassembledLabel) {
      // Re-use label
      label = targetContent.label;
      labelReused = true;
    } else {
      if (instruction.mnemonic == Mnemonic.call) {
        label = 'call_${_nextCallLabelIndex++}';
      } else {
        label = 'jump_${_nextJumpLabelIndex++}';
      }
    }

    // Replace immediate operand with a label reference
    _lines[_i] = DisassemblyLine(
      line.address,
      DisassembledInstruction(instruction.mnemonic,
        operand1: LabelOperand(label),
        operand2: instruction.operand2
      ),
      line.rawBytes
    );
    
    if (!labelReused) {
      // Insert a label at the target
      _insertLabel(label, addressIndex);
    }
  }

  /// [operandIndex] must be either 1 or 2.
  void _tryLabelOperandMemory(int operandIndex) {
    assert(operandIndex == 1 || operandIndex == 2);

    final DisassemblyLine line = _lines[_i];
    final DisassembledContent content = line.content;

    // Ensure line is an instruction
    if (line.content is! DisassembledInstruction) {
      return;
    }

    final DisassembledInstruction instruction = content;

    final InstructionOperand operand = operandIndex == 1
      ? instruction.operand1
      : instruction.operand2;

    // Ensure operand is a memory reference
    if (operand is! MemoryInstructionOperand) {
      return;
    }

    final MemoryInstructionOperand memoryOperand = operand;

    // Ensure memory value is an immediate
    if (memoryOperand.value is! ImmediateOperand) {
      return;
    }

    final ImmediateOperand immediate = memoryOperand.value;

    // Get the target address
    final int address = immediate.value;
    final int addressIndex = _getAddressIndex(address);

    // Ensure the target address is in the binary
    if (addressIndex == null) {
      return;
    }

    // Label the target
    String label;
    bool labelReused = false;

    final DisassembledContent targetContent = _lines[addressIndex].content;
    if (targetContent is DisassembledLabel) {
      // Re-use label
      label = targetContent.label;
      labelReused = true;
    } else {
      label = 'data_${_nextDataLabelIndex++}';
    }

    // Replace immediate value with a label reference
    final newOperand = MemoryInstructionOperand(LabelOperand(label),
      displacement: memoryOperand.displacement
    );

    _lines[_i] = DisassemblyLine(
      line.address,
      DisassembledInstruction(instruction.mnemonic,
        operand1: operandIndex == 1 ? newOperand : instruction.operand1,
        operand2: operandIndex == 2 ? newOperand : instruction.operand2
      ),
      line.rawBytes
    );
    
    if (!labelReused) {
      // Insert a label at the target
      _insertLabel(label, addressIndex);
    }
  }

  void _reinterpretAsDw() {
    final DisassemblyLine line = _lines[_i];

    // Ensure line is an instruction
    if (line.content is! DisassembledInstruction) {
      return;
    }

    // Remove the line
    _lines.removeAt(_i);

    // Replace it with 1 DW directive per word
    final int words = line.rawBytes.length ~/ 2;

    for (int i = 0; i < words; i++) {
      final int upper = line.rawBytes[i * 2];
      final int lower = line.rawBytes[(i * 2) + 1];

      final int word = lower | (upper << 8);

      _lines.insert(_i, DisassemblyLine(
        line.address + i,
        DisassembledDwDirective([DwOperand(word)]),
        Uint8List.view(
          line.rawBytes.buffer, 
          line.rawBytes.offsetInBytes + (i * 2), 
          2
        )
      ));
    }

    _i += (words - 1);
  }

  void _insertLabel(String label, int atAddress) {
    // Insert a label at the address
    _lines.insert(atAddress, DisassemblyLine(
      null, 
      DisassembledLabel(label),
      null
    ));
  
    // Skip an index if the inserted line was before
    // the current line
    if (atAddress <= _i) {
      _i++;
    }
  }

  /// Gets the index of the line with the specified [address].
  int _getAddressIndex(int address) {
    int lastAddress = null;
    DisassemblyLine lastLine = null;

    // TODO: Implement faster search algorithm
    for (int i = 0; i < _lines.length; i++) {
      final DisassemblyLine line = _lines[i];

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

  bool _isJumpOrCallMnemonic(Mnemonic mnemonic) {
    return mnemonic == Mnemonic.call
      || mnemonic == Mnemonic.ja
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
}