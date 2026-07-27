import 'dart:math' as math;
import 'dart:ui';

import '../../domain/entities/org_tree.dart';

/// Fixed geometry of the chart. Cards are a constant size so the layout can be
/// solved analytically and every node animates between two known positions.
class OrgMetrics {
  const OrgMetrics._();

  static const double nodeWidth = 220;
  static const double nodeHeight = 168;
  static const double horizontalGap = 22;
  static const double verticalGap = 76;
  static const double canvasPadding = 64;
}

class PositionedNode {
  final OrgNode node;
  final Offset topLeft;
  final int depth;
  final bool expanded;

  const PositionedNode({
    required this.node,
    required this.topLeft,
    required this.depth,
    required this.expanded,
  });

  String get id => node.id;

  Offset get center => Offset(
        topLeft.dx + OrgMetrics.nodeWidth / 2,
        topLeft.dy + OrgMetrics.nodeHeight / 2,
      );
}

class OrgEdge {
  final Offset from;
  final Offset to;
  final bool highlighted;

  const OrgEdge({
    required this.from,
    required this.to,
    this.highlighted = false,
  });
}

class OrgLayout {
  final List<PositionedNode> nodes;
  final List<OrgEdge> edges;
  final Size size;

  const OrgLayout({
    required this.nodes,
    required this.edges,
    required this.size,
  });

  static const OrgLayout empty =
      OrgLayout(nodes: [], edges: [], size: Size.zero);

  PositionedNode? nodeById(String id) {
    for (final node in nodes) {
      if (node.id == id) return node;
    }
    return null;
  }
}

/// Solves node positions for the currently visible tree.
///
/// This replaces the nested `Row`/`Column` + `LayoutBuilder` connector hack in
/// the original screen, which could not draw an accurate line between a parent
/// and children of differing subtree widths. Here every card is absolutely
/// positioned, so connectors are exact and every change is animatable.
OrgLayout computeOrgLayout({
  required OrgNode? root,
  required Set<String> expandedIds,
  Set<String> highlightIds = const {},
}) {
  if (root == null) return OrgLayout.empty;

  final widths = <String, double>{};

  bool isExpanded(OrgNode node) =>
      node.hasChildren && expandedIds.contains(node.id);

  double subtreeWidth(OrgNode node) {
    final cached = widths[node.id];
    if (cached != null) return cached;

    double width = OrgMetrics.nodeWidth;
    if (isExpanded(node)) {
      double total = 0;
      for (var i = 0; i < node.children.length; i++) {
        total += subtreeWidth(node.children[i]);
        if (i != node.children.length - 1) total += OrgMetrics.horizontalGap;
      }
      width = math.max(width, total);
    }
    widths[node.id] = width;
    return width;
  }

  final nodes = <PositionedNode>[];
  final edges = <OrgEdge>[];
  var maxDepth = 0;

  double yFor(int depth) =>
      OrgMetrics.canvasPadding +
      depth * (OrgMetrics.nodeHeight + OrgMetrics.verticalGap);

  void place(OrgNode node, double left, int depth) {
    final width = subtreeWidth(node);
    final centerX = left + width / 2;
    final y = yFor(depth);
    maxDepth = math.max(maxDepth, depth);

    nodes.add(PositionedNode(
      node: node,
      topLeft: Offset(centerX - OrgMetrics.nodeWidth / 2, y),
      depth: depth,
      expanded: isExpanded(node),
    ));

    if (!isExpanded(node)) return;

    var childrenTotal = 0.0;
    for (var i = 0; i < node.children.length; i++) {
      childrenTotal += subtreeWidth(node.children[i]);
      if (i != node.children.length - 1) {
        childrenTotal += OrgMetrics.horizontalGap;
      }
    }

    var childLeft = centerX - childrenTotal / 2;
    for (final child in node.children) {
      final childWidth = subtreeWidth(child);
      edges.add(OrgEdge(
        from: Offset(centerX, y + OrgMetrics.nodeHeight),
        to: Offset(childLeft + childWidth / 2, yFor(depth + 1)),
        highlighted: highlightIds.contains(child.id) ||
            highlightIds.contains(node.id),
      ));
      place(child, childLeft, depth + 1);
      childLeft += childWidth + OrgMetrics.horizontalGap;
    }
  }

  place(root, OrgMetrics.canvasPadding, 0);

  final width = subtreeWidth(root) + OrgMetrics.canvasPadding * 2;
  final height = yFor(maxDepth) + OrgMetrics.nodeHeight + OrgMetrics.canvasPadding;

  return OrgLayout(
    nodes: nodes,
    edges: edges,
    size: Size(width, height),
  );
}
