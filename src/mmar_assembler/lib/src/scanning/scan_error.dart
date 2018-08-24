import 'package:meta/meta.dart';
import 'package:source_span/source_span.dart';

@immutable
class ScanError {
  final SourceSpan sourceSpan;
  final String message;

  const ScanError({
    @required this.sourceSpan,
    @required this.message
  });
}