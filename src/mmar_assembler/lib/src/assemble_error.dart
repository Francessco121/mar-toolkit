import 'package:meta/meta.dart';
import 'package:source_span/source_span.dart';

@immutable
class AssembleError {
  final SourceSpan sourceSpan;
  final String message;

  const AssembleError(this.sourceSpan, this.message);
}