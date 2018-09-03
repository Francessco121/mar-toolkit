import 'line.dart';
import 'line_visitor.dart';

class Constant implements Line {
  @override
  String comment;
  
  String get identifier => _identifier;

  set identifier(String value) {
    assert(value != null);
    _identifier = value;
  }

  int get value => _value;

  set value(int value) {
    assert(value != null);
    _value = value;
  }

  String _identifier;
  int _value;

  Constant(String identifier, int value, {this.comment})
    : assert(identifier != null),
      assert(value != null),
      _identifier = identifier,
      _value = value;

  @override
  void accept(LineVisitor visitor) {
    visitor.visitConstant(this);
  }
}