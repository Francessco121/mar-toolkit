import '../ir/ir.dart';

/// Removes all unused constant and label definitions from the given MAR source [lines].
void removeUnusedIdentifiers(List<Line> lines) {
  // Get a set of all identifiers that are being used
  final usedIdentifierFinder = new _UsedIdentifierFinder();

  for (final Line line in lines) {
    line.accept(usedIdentifierFinder);
  }

  // Remove unused identifiers
  final Set<String> usedIdentifiers = usedIdentifierFinder.usedIdentifiers;

  for (int i = 0; i < lines.length; i++) {
    final Line line = lines[i];

    if (line is Constant && !usedIdentifiers.contains(line.identifier)) {
      lines.removeAt(i);
      i--;
    } else if (line is Label && !usedIdentifiers.contains(line.label)) {
      lines.removeAt(i);
      i--;
    } else if (line is Labelable) {
      final Labelable labelable = line as Labelable;

      if (!usedIdentifiers.contains(labelable.label)) {
        labelable.label = null;
      }
    }
  }
}

class _UsedIdentifierFinder implements LineVisitor {
  final usedIdentifiers = new Set<String>();

  @override
  void visitComment(_) { }

  @override
  void visitConstant(_) { }

  @override
  void visitDwDirective(_) { }

  @override
  void visitInstruction(Instruction instruction) {
    if (instruction.operand1 != null) {
      _visitInstructionOperand(instruction.operand1);
    }

    if (instruction.operand2 != null) {
      _visitInstructionOperand(instruction.operand2);
    }
  }

  @override
  void visitLabel(_) { }

  @override
  void visitOrgDirective(_) { }

  @override
  void visitSection(_) { }

  void _visitInstructionOperand(InstructionOperand operand) {
    if (operand is ConstOperand) {
      usedIdentifiers.add(operand.constIdentifier);
    } else if (operand is LabelOperand) {
      usedIdentifiers.add(operand.labelIdentifier);
    } else if (operand is MemoryInstructionOperand) {
      final MemoryOperand value = operand.value;
      final DisplacementOperand displacement = operand.displacement?.value;

      if (value is ConstOperand) {
        usedIdentifiers.add(value.constIdentifier);
      } else if (value is LabelOperand) {
        usedIdentifiers.add(value.labelIdentifier);
      }

      if (displacement != null) {
        if (displacement is ConstOperand) {
          usedIdentifiers.add(displacement.constIdentifier);
        } else if (displacement is LabelOperand) {
          usedIdentifiers.add(displacement.labelIdentifier);
        }
      }
    }
  }
}