import 'dart:async';
import 'dart:io' as io;

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

  /// Throws a [FileSystemException] if the file could not be read,
  /// or another IO error occurred.
  static Future<Source> createFromFile(String path) async {
    final file = new io.File(path);
    final contents = await file.readAsString();

    return Source(file.uri, contents);
  }
}