import 'line.dart';
import 'line_visitor.dart';

class Section implements Line {
  @override
  String comment;
  
  String get identifier => _identifier;

  set identifier(String value) {
    assert(value != null);
    _identifier = value;
  }

  String _identifier;

  Section(String identifier, {this.comment})
    : assert(identifier != null),
      _identifier = identifier;

  @override
  void accept(LineVisitor visitor) {
    visitor.visitSection(this);
  }
}