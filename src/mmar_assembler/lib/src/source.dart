class Source {
  /// Whether this source is marked with the `#once` directive
  /// and has already been included once.
  bool get includedOnce => _includedOnce;
  bool _includedOnce = false;

  final Uri uri;
  final String contents;

  Source(this.uri, this.contents);

  void setIncludedOnce() {
    _includedOnce = true;
  }
}