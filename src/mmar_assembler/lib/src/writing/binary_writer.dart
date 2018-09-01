import 'dart:collection';
import 'dart:typed_data';

import 'ir/ir.dart' as ir;

UnmodifiableListView<Uint8List> writeBinary(List<ir.Line> lines, {int chunkSize = 2048}) {
  assert(lines != null);
  assert(chunkSize != null);

  final visitor = new _LineVisitor(chunkSize);

  // Generate the full list of binary data
  for (final ir.Line line in lines) {
    line.accept(visitor);
  }

  // Go back and resolve references to labels
  for (final reference in visitor.unresolvedReferences) {
    // Get the address of the label
    int labelAddress = visitor.labels[reference.label];
    assert(labelAddress != null);

    if (reference.negate) {
      // Negation is requested if this label is a displacement
      // operand when the displacement operator is minus
      labelAddress = -labelAddress;
    }

    if (visitor.addressOffset != null) {
      // Offset the address by the ORG value
      labelAddress += visitor.addressOffset;
    }

    // Overwrite the placeholder with the correct address
    final Uint8List chunk = visitor.chunks[(reference.address / chunkSize).floor()];
    chunk[reference.address % chunkSize] = labelAddress;
  }

  // Replace the last chunk with a view if it is smaller than the chunk size
  if (visitor.chunks.isNotEmpty && visitor.lengthOfLastChunk < chunkSize) {
    final Uint8List lastChunk = visitor.chunks.last;
    visitor.chunks.last = Uint8List.view(lastChunk.buffer, 0, visitor.lengthOfLastChunk);
  }

  return UnmodifiableListView(visitor.chunks);
}

/// Represents an address that needs to have its value
/// changed to be the address of a label.
/// 
/// These are the product of the first pass of writing
/// the IR to binary, and are resolved on the second pass.
class _UnresolvedLabelReference {
  /// The address of the unresolved reference.
  final int address;
  /// The name of the label.
  final String label;
  /// Whether the value should be negated before
  /// being written to the [address].
  final bool negate;

  _UnresolvedLabelReference(this.address, this.label, {this.negate = false});
}

class _LineVisitor implements ir.LineVisitor {
  /// The binary data split into fixed size chunks.
  final List<Uint8List> chunks = [];

  /// The length of the last chunk.
  int get lengthOfLastChunk => _currentChunkIndex;

  /// A map of labels to their addresses
  final Map<String, int> labels = {};

  /// A list of label references that need to be resolved.
  final List<_UnresolvedLabelReference> unresolvedReferences = [];

  /// The global address offset to use when resolving label references.
  /// 
  /// Will be `null` if no `ORG` directive was visited.
  int get  addressOffset => _addressOffset;

  int get _currentAddress => chunks.length;

  int _addressOffset = null;
  int _currentChunkIndex = 0;
  Uint8List _currentChunk;

  /// A map of constant identifiers to their values
  final Map<String, int> _constants = {};
  final int _chunkSize;

  _LineVisitor(this._chunkSize) {
    assert(_chunkSize != null);
    assert(_chunkSize > 0);

    _currentChunk = new Uint8List(_chunkSize);
    chunks.add(_currentChunk);
  }

  @override
  void visitComment(ir.Comment comment) { }

  @override
  void visitConstant(ir.Constant constant) {
    _constants[constant.identifier] = constant.value;
  }

  @override
  void visitDwDirective(ir.DwDirective dwDirective) {
    if (dwDirective.label != null) {
      _markLabelAsCurrent(dwDirective.label);
    }

    for (final ir.DwOperand operand in dwDirective.operands) {
      final dynamic value = operand.duplicate ?? operand.value;
      final int count = operand.duplicate != null ? operand.value as int : 1;

      // Despite the 'duplicate' value appearing inside the DUP expression,
      // it is not the number of times to be duplicated and instead switches
      // the definition of the 'value' to be the duplication count.

      for (int i = 0; i < count; i++) {
        if (value is String) {
          for (final int char in value.codeUnits) {
            _write(char);
          }
        } else {
          _write(value as int);
        }
      }
    }
  }

  @override
  void visitInstruction(ir.Instruction instruction) {
    if (instruction.label != null) {
      _markLabelAsCurrent(instruction.label);
    }

    // Get the instruction definition
    final ir.InstructionDefinition instructionDefinition
      = ir.mnemonicsToInstructionDefs[instruction.mnemonic];

    // Build the instruction
    int instructionWord = 0;

    // Encode the instruction opcode (bits 0-5)
    instructionWord |= instructionDefinition.opcode;

    // Get the source and destination selectors
    int sourceSelector = 0;
    int destSelector = 0;

    if (instruction.operand2 == null) {
      sourceSelector = _getOperandSelector(instruction.operand1);
    } else {
      sourceSelector = _getOperandSelector(instruction.operand2);
      destSelector = _getOperandSelector(instruction.operand1);
    }

    // Encode the destination selector (bits 6-10)
    instructionWord |= (destSelector << 6);

    // Encode the source selector (bits 11-15)
    instructionWord |= (sourceSelector << 11);

    // Write the instruction
    _write(instructionWord);

    // Write the source word
    if (instruction.operand1 != null) {
      _writeOperand(instruction.operand1);
    }

    // Write the destination word
    if (instruction.operand2 != null) {
      _writeOperand(instruction.operand2);
    }
  }

  @override
  void visitLabel(ir.Label label) {
    _markLabelAsCurrent(label.label);
  }

  @override
  void visitOrgDirective(ir.OrgDirective orgDirective) {
    _addressOffset = orgDirective.value;
  }

  @override
  void visitSection(_) {
    // Sections do not mean anything to the binary writer.
    // It is assumed that the IR is already in the order
    // that is meant to be written.
  }

  void _writeLabelOperand(ir.LabelOperand operand, {bool negate}) {
    // We don't necessarily know the address of the label yet,
    // so add a placeholder word and mark it as unresolved.
    unresolvedReferences.add(_UnresolvedLabelReference(
      _currentAddress,
      operand.labelIdentifier
    ));

    _write(0);
  }

  void _writeDisplacement(ir.Displacement displacement) {
    final ir.DisplacementOperand operand = displacement.value;

    if (operand is ir.ImmediateOperand) {
      _write(operand.value);
    } else if (operand is ir.LabelOperand) {
      _writeLabelOperand(operand,
        negate: displacement.$operator == ir.DisplacementOperator.minus
      );
    } else if (operand is ir.ConstOperand) {
      _write(_constants[operand.constIdentifier]);
    }
  }

  void _writeMemoryOperand(ir.MemoryInstructionOperand operand) {
      if (operand.displacement != null) {
      // Don't write the memory value since it must be a register
      // if a displacement exists, which has already been encoded
      // into the operand selector.
      _writeDisplacement(operand.displacement);
    } else {
      final ir.MemoryOperand value = operand.value;

      if (value is ir.ConstOperand) {
        _write(_constants[value.constIdentifier]);
      } else if (value is ir.ImmediateOperand) {
        _write(value.value);
      } else if (value is ir.LabelOperand) {
        _writeLabelOperand(value);
      }

      // The other possibility is the value being a register,
      // in which case it has already been encoded into the
      // operand selector.
    }
  }

  void _writeOperand(ir.InstructionOperand operand) {
    if (operand is ir.ConstOperand) {
      _write(_constants[operand.constIdentifier]);
    } else if (operand is ir.ImmediateOperand) {
      _write(operand.value);
    } else if (operand is ir.LabelOperand) {
      _writeLabelOperand(operand);
    } else if (operand is ir.MemoryInstructionOperand) {
      _writeMemoryOperand(operand);
    }
  }

  void _write(int word) {
    _currentChunk[_currentChunkIndex++] = word >> 8;
    _currentChunk[_currentChunkIndex++] = word;

    if (_currentChunkIndex >= _currentChunk.length) {
      _currentChunk = new Uint8List(_chunkSize);
      _currentChunkIndex = 0;
      chunks.add(_currentChunk);
    }
  }

  /// Marks the given [label] as being at the current address.
  void _markLabelAsCurrent(String label) {
    labels[label] = _currentAddress;
  }

  int _getOperandSelector(ir.InstructionOperand operand) {
    return operand == null ? 0 : operand.selector;
  }
}