import 'parsing/ast/ast.dart' as ast;
import 'source_tree.dart';
import 'source.dart';

class AssemblerState {
  /// A tree representing how each source file includes eachother.
  final SourceTree sourceTree;

  /// A map of source URIs to their source.
  /// 
  /// Only includes sources that have been included so far and the entry source.
  final Map<Uri, Source> sources = {};

  /// A map of source URIs to their post-macro-compilation AST.
  final Map<Uri, List<ast.Line>> sourceLines = {};

  AssemblerState(Source rootSource)
    : assert(rootSource != null),
      sourceTree = SourceTree(rootSource.uri) {

    sources[rootSource.uri] = rootSource;
  }
}