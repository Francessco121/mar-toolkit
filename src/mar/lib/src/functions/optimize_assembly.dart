import '../ir/ir.dart';
import '../mnemonic.dart';

/// Optimizes the given list of MAR source [lines].
/// 
/// The entire list of [lines] will be iterated over at a maximum
/// number of times specified by [passes]. Sources cannot always
/// be fully optimized in one pass. If the optimizer determines that
/// no further optimizations can be made, it may perform fewer
/// [passes] than specified.
/// 
/// Stack optimizations can be turned on by setting [doStackOptimizations] to `true`.
/// These are disabled by default as they may break code if the code references
/// memory below the stack pointer.
void optimizeAssembly(List<Line> lines, {int passes = 1, bool doStackOptimizations = false}) {
  assert(passes != null);
  assert(doStackOptimizations != null);

  final optimizer = new _Optimizer(lines);

  optimizer.optimize(passes, 
    stackOptimizations: doStackOptimizations
  );
}

class _Optimizer {
  Line _currentLine;
  Line _lastNonCommentLine;
  int _lastNonCommentI;
  bool _dontUpdateLast = false;
  bool _changesMade = false;

  int _i;

  final List<Line> _lines;

  _Optimizer(this._lines)
    : assert(_lines != null);

  void optimize(int passes, {bool stackOptimizations = false}) {
    for (int pass = 0; pass < passes; pass++) {
      _changesMade = false;
      _lastNonCommentLine = null;
      _lastNonCommentI = null;
      _dontUpdateLast = false;

      // Run pass
      for (_i = 0; _i < _lines.length; _i++) {
        _currentLine = _lines[_i];

        // Skip comments
        if (_currentLine is Comment) {
          continue;
        }

        // Safe optimizations
        _redundantMov();
        _overwrittenMov();
        _sameMovOperands();
        _jumpToNextInstruction();

        // Stack optimizations (if enabled)
        if (stackOptimizations) {
          _omitSequentialPushAndPopToSameDestination();
          _condenseSequentialPushAndPop();
        }

        if (!_dontUpdateLast) {
          // Save line
          _lastNonCommentLine = _currentLine;
          _lastNonCommentI = _i;
        } else {
          _dontUpdateLast = false;
        }
      }

      // Stop early if no changes were made
      if (!_changesMade) {
        break;
      }
    }
  }

  void _redundantMov() {
    final Line current = _current();
    final Line previous = _previous();

    if (current is Instruction && previous is Instruction) {
      if (current.label != null) {
        return;
      }

      if (current.mnemonic == Mnemonic.mov && previous.mnemonic == Mnemonic.mov) {
        // Current mov is redundant if it's the reverse of the previous
        if (_operandsEqual(previous.operand1, current.operand2) 
          && _operandsEqual(previous.operand2, current.operand1)
        ) {
          _removeCurrent();
        }
      }
    }
  }

  void _overwrittenMov() {
    final Line current = _current();
    final Line previous = _previous();

    if (current is Instruction && previous is Instruction) {
      if (previous.label != null) {
        return;
      }

      if (current.mnemonic == Mnemonic.mov && previous.mnemonic == Mnemonic.mov) {
        // Previous mov is redundant if it was writing to the same destination as the current
        if (_operandsEqual(previous.operand1, current.operand1)) {
          _removePrevious();
        }
      }
    }
  }

  void _sameMovOperands() {
    final Line current = _current();

    if (current is Instruction) {
      if (current.label != null) {
        return;
      }

      if (current.mnemonic == Mnemonic.mov) {
        // Current mov is redundant if it's destination and source are the same thing
        if (_operandsEqual(current.operand1, current.operand2)) {
          _removeCurrent();
        }
      }
    }
  }

  void _jumpToNextInstruction() {
    final Line current = _current();
    final Line previous = _previous();

    if (previous is Instruction) {
      if (previous.label != null) {
        return;
      }

      if (!_isJumpMnemonic(previous.mnemonic)) {
        return;
      }

      final InstructionOperand targetOperand = previous.operand1;

      if (targetOperand is LabelOperand) {
        // Previous jump is redundant if the current line has the label it's jumping to
        if (current is Label && current.label == targetOperand.labelIdentifier) {
          _removePrevious();
        } else if (current is Instruction && current.label == targetOperand.labelIdentifier) {
          _removePrevious();
        }
      }
    }
  }

  /// Note: This is a stack optimization.
  void _omitSequentialPushAndPopToSameDestination() {
    final Line current = _current();
    final Line previous = _previous();

    if (current is Instruction && previous is Instruction) {
      if (current.label != null || previous.label != null) {
        return;
      }

      if (current.mnemonic == Mnemonic.pop && previous.mnemonic == Mnemonic.push) {
        if (_operandsEqual(previous.operand1, current.operand1)) {
          // Sequential push and pop to and from the same destination can be removed entirely
          _removeCurrent();
          _removePrevious();
        }
      }
    }
  }

  /// Note: This is a stack optimization.
  void _condenseSequentialPushAndPop() {
    final Line current = _current();
    final Line previous = _previous();

    if (current is Instruction && previous is Instruction) {
      if (current.label != null || previous.label != null) {
        return;
      }

      if (current.mnemonic == Mnemonic.pop && previous.mnemonic == Mnemonic.push) {
        // Sequential push and pop can be condensed into a single mov
        _removeCurrent();
        _replacePrevious(Instruction(Mnemonic.mov,
          operand1: current.operand1,
          operand2: previous.operand1
        ));
      }
    }
  }

  void _removeCurrent() {
    _lines.removeAt(_i);
    _i--;
    _currentLine = null;
    _dontUpdateLast = true;

    _changesMade = true;
  }

  void _removePrevious() {
    _lines.removeAt(_lastNonCommentI);
    _i--;
    _lastNonCommentI = null;
    _lastNonCommentLine = null;

    _changesMade = true;
  }

  void _replacePrevious(Line withLine) {
    _lines[_lastNonCommentI] = withLine;
    _lastNonCommentLine = withLine;

    _changesMade = true;
  }

  bool _operandsEqual(InstructionOperand operand1, InstructionOperand operand2) {
    if (operand1 is ConstOperand && operand2 is ConstOperand) {
      // Const reference
      return operand1.constIdentifier == operand2.constIdentifier;
    } else if (operand1 is LabelOperand && operand2 is LabelOperand) {
      // Label reference
      return operand1.labelIdentifier == operand2.labelIdentifier;
    } else if (operand1 is ImmediateOperand && operand2 is ImmediateOperand) {
      // Immediate
      return operand1.value == operand2.value;
    } else if (operand1 is RegisterOperand && operand2 is RegisterOperand) {
      // Register
      return operand1.register == operand2.register;
    } else if (operand1 is MemoryInstructionOperand && operand2 is MemoryInstructionOperand) {
      // Memory
      return _memoryOperandsEqual(operand1.value, operand2.value)
        && _displacementOperandsEqual(operand1.displacement?.value, operand2.displacement?.value)
        && operand1.displacement?.$operator == operand2.displacement?.$operator;
    } else {
      return false;
    }
  }

  bool _memoryOperandsEqual(MemoryOperand operand1, MemoryOperand operand2) {
    if (operand1 is ConstOperand && operand2 is ConstOperand) {
      // Const reference
      return operand1.constIdentifier == operand2.constIdentifier;
    } else if (operand1 is LabelOperand && operand2 is LabelOperand) {
      // Label reference
      return operand1.labelIdentifier == operand2.labelIdentifier;
    } else if (operand1 is ImmediateOperand && operand2 is ImmediateOperand) {
      // Immediate
      return operand1.value == operand2.value;
    } else if (operand1 is RegisterOperand && operand2 is RegisterOperand) {
      // Register
      return operand1.register == operand2.register;
    } else {
      return false;
    }
  }

  bool _displacementOperandsEqual(DisplacementOperand operand1, DisplacementOperand operand2) {
    if (operand1 is ConstOperand && operand2 is ConstOperand) {
      // Const reference
      return operand1.constIdentifier == operand2.constIdentifier;
    } else if (operand1 is LabelOperand && operand2 is LabelOperand) {
      // Label reference
      return operand1.labelIdentifier == operand2.labelIdentifier;
    } else if (operand1 is ImmediateOperand && operand2 is ImmediateOperand) {
      // Immediate
      return operand1.value == operand2.value;
    } else {
      return false;
    }
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

  Line _current() {
    return _currentLine;
  }

  Line _previous() {
    return _lastNonCommentLine;
  }
}