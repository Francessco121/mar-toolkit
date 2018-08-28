class SourceTree {
  final SourceTreeNode root;

  SourceTree(Uri rootSourceUri)
    : root = SourceTreeNode(rootSourceUri);
}

class SourceTreeNode {
  final Uri uri;
  final SourceTreeNode parent;
  final List<SourceTreeNode> children = [];

  SourceTreeNode(this.uri, {this.parent});

  SourceTreeNode addChild(Uri childSourceUri) {
    final child = SourceTreeNode(childSourceUri, parent: this);
    children.add(child);

    return child;
  }

  SourceTreeNode getAncestor(Uri sourceUri) {
    SourceTreeNode parent = this.parent;
    while (parent != null) {
      if (parent.uri == sourceUri) {
        return parent;
      }

      parent = parent.parent;
    }

    return null;
  }

  List<SourceTreeNode> getAncestors({Uri untilSourceUri}) {
    final List<SourceTreeNode> ancestors = [];

    SourceTreeNode parent = this.parent;
    while (parent != null) {
      if (parent.uri == untilSourceUri) {
        break;
      }

      ancestors.add(parent);
      parent = parent.parent;
    }

    return ancestors;
  }
}