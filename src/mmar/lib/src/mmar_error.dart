import 'package:meta/meta.dart';
import 'package:source_span/source_span.dart';

@immutable
class MmarError {
  final SourceSpan sourceSpan;
  final String message;

  const MmarError(this.sourceSpan, this.message);
}