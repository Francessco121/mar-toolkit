enum SelectorType {
  /// No operand.
  /// 
  /// Bit-pattern: `00000`
  none,

  /// The selector could not be determined.
  unknown,

  /// Operand is a register, which is encoded in the selector.
  /// 
  /// The bit pattern is the register index.
  /// 
  /// Bit-pattern: `00001` - `01000`
  register16,

  /// The operand is a value stored at the address specified
  /// by the operand word.
  /// 
  /// Bit-pattern: `11110`
  memoryImmediate16,

  /// The operand is a value stored at the address specified
  /// by the register encoded in the selector.
  /// 
  /// The bit pattern is the register index added to `0x8` (`0b1000`).
  /// 
  /// Bit-pattern: `01001` - `10000`
  memoryRegister16,

  /// The operand is a value stored at the address specified
  /// by the register encoded in the selector plus the word operand.
  /// 
  /// The bit pattern is the register index added to `0x10` (`0b1_0000`).
  /// 
  /// Bit-pattern: `10001` - `11000`
  memoryRegisterDisplaced16,

  /// The operand is the value of the operand word.
  /// 
  /// Bit-pattern: `11111`
  immediate16
}