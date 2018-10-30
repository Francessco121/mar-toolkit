import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:source_span/source_span.dart';

class HlmlProblem {
  final SourceSpan sourceSpan;
  final String message;

  const HlmlProblem(this.sourceSpan, this.message);
}

class HlmlProblems {
  final UnmodifiableListView<HlmlProblem> errors;
  final UnmodifiableListView<HlmlProblem> warnings;

  HlmlProblems({
    @required this.errors, 
    @required this.warnings
  }) {
    if (errors == null) throw ArgumentError.notNull('errors');
    if (warnings == null) throw ArgumentError.notNull('warnings');
  }
}

class HlmlProblemsBuilder {
  final List<HlmlProblem> _errors = [];
  final List<HlmlProblem> _warnings = [];

  void addError(SourceSpan sourceSpan, String message) {
    _errors.add(HlmlProblem(sourceSpan, message));
  }

  void addWarning(SourceSpan sourceSpan, String message) {
    _warnings.add(HlmlProblem(sourceSpan, message));
  }

  HlmlProblems build() {
    return HlmlProblems(
      errors: UnmodifiableListView(_errors),
      warnings: UnmodifiableListView(_warnings)
    );
  }
}