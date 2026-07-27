import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/entities/employee.dart';
import '../../domain/entities/org_tree.dart';
import '../layout/org_layout.dart';
import '../theme/directory_tokens.dart';
import 'appear_once.dart';
import 'connector_painter.dart';
import 'org_node_card.dart';

/// The zoomable, pannable org chart.
///
/// Zoom in the original screen never worked: `_zoomIn()` mutated the matrix in
/// place and assigned the *same object* back to the `TransformationController`,
/// so the `ValueNotifier` compared old == new and never notified — no repaint.
/// Every transform here is a new `Matrix4`, animated, clamped, and pivoted on
/// the viewport centre.
class OrgChartCanvas extends StatefulWidget {
  final OrgNode? root;
  final Set<String> expandedIds;
  final Set<String> matchedIds;
  final bool isFiltering;
  final String? selectedId;
  final String? focusId;
  final Department? Function(String departmentId) departmentOf;
  final Company? Function(String companyId) companyOf;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onOpen;
  final ValueChanged<String> onQuickActions;
  final VoidCallback onFocusHandled;

  const OrgChartCanvas({
    super.key,
    required this.root,
    required this.expandedIds,
    required this.matchedIds,
    required this.isFiltering,
    required this.selectedId,
    required this.focusId,
    required this.departmentOf,
    required this.companyOf,
    required this.onToggle,
    required this.onOpen,
    required this.onQuickActions,
    required this.onFocusHandled,
  });

  @override
  State<OrgChartCanvas> createState() => _OrgChartCanvasState();
}

class _OrgChartCanvasState extends State<OrgChartCanvas>
    with TickerProviderStateMixin {
  static const double _minScale = 0.25;
  static const double _maxScale = 2.5;

  final TransformationController _transform = TransformationController();

  late final AnimationController _zoomController = AnimationController(
    vsync: this,
    duration: DirMotion.base,
  );
  late final AnimationController _drawController = AnimationController(
    vsync: this,
    duration: DirMotion.slow,
  );

  Animation<Matrix4>? _zoomAnimation;
  OrgLayout _layout = OrgLayout.empty;
  Size _viewport = Size.zero;
  double _scale = 1;
  bool _didInitialFit = false;
  TapDownDetails? _lastDoubleTap;

  @override
  void initState() {
    super.initState();
    _transform.addListener(_syncScale);
    _zoomController.addListener(() {
      final value = _zoomAnimation?.value;
      if (value != null) _transform.value = value;
    });
    _drawController.forward();
  }

  void _syncScale() {
    final next = _transform.value.getMaxScaleOnAxis();
    if ((next - _scale).abs() > 0.005) {
      setState(() => _scale = next);
    }
  }

  @override
  void didUpdateWidget(covariant OrgChartCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.expandedIds != oldWidget.expandedIds ||
        widget.matchedIds != oldWidget.matchedIds) {
      _drawController.forward(from: 0);
    }

    final focusId = widget.focusId;
    if (focusId != null && focusId != oldWidget.focusId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusOn(focusId);
        widget.onFocusHandled();
      });
    }
  }

  @override
  void dispose() {
    _transform.removeListener(_syncScale);
    _transform.dispose();
    _zoomController.dispose();
    _drawController.dispose();
    super.dispose();
  }

  // ── Transform helpers ─────────────────────────────────────────────────────

  void _animateTo(Matrix4 target) {
    _zoomAnimation = Matrix4Tween(begin: _transform.value, end: target)
        .animate(CurvedAnimation(parent: _zoomController, curve: DirMotion.settle));
    _zoomController.forward(from: 0);
  }

  Matrix4 _matrixFor({required double scale, required Offset translation}) =>
      Matrix4.identity()
        ..translate(translation.dx, translation.dy)
        ..scale(scale);

  void _zoomBy(double factor) {
    final current = _transform.value;
    final scale = current.getMaxScaleOnAxis();
    final next = (scale * factor).clamp(_minScale, _maxScale).toDouble();
    final ratio = next / scale;

    final tx = current.storage[12];
    final ty = current.storage[13];
    final cx = _viewport.width / 2;
    final cy = _viewport.height / 2;

    _animateTo(_matrixFor(
      scale: next,
      translation: Offset(
        cx - ratio * (cx - tx),
        cy - ratio * (cy - ty),
      ),
    ));
  }

  /// Scales the whole chart to fit, then centres it.
  void _fitToScreen({bool animate = true}) {
    if (_layout.size == Size.zero || _viewport == Size.zero) return;

    final scale = math
        .min(
          _viewport.width / _layout.size.width,
          _viewport.height / _layout.size.height,
        )
        .clamp(_minScale, 1.0)
        .toDouble();

    final target = _matrixFor(
      scale: scale,
      translation: Offset(
        (_viewport.width - _layout.size.width * scale) / 2,
        (_viewport.height - _layout.size.height * scale) / 2,
      ),
    );

    if (animate) {
      _animateTo(target);
    } else {
      _transform.value = target;
    }
  }

  void _focusOn(String nodeId, {double? scale}) {
    final node = _layout.nodeById(nodeId);
    if (node == null || _viewport == Size.zero) return;

    final targetScale =
        (scale ?? math.max(_scale, 0.9)).clamp(_minScale, _maxScale).toDouble();

    _animateTo(_matrixFor(
      scale: targetScale,
      translation: Offset(
        _viewport.width / 2 - targetScale * node.center.dx,
        _viewport.height / 2.4 - targetScale * node.center.dy,
      ),
    ));
  }

  void _handleDoubleTap() {
    final position = _lastDoubleTap?.localPosition;
    if (_scale > 1.1 || position == null) {
      _fitToScreen();
      return;
    }
    const target = 1.35;
    final current = _transform.value;
    final scale = current.getMaxScaleOnAxis();
    final ratio = target / scale;
    final tx = current.storage[12];
    final ty = current.storage[13];

    _animateTo(_matrixFor(
      scale: target,
      translation: Offset(
        position.dx - ratio * (position.dx - tx),
        position.dy - ratio * (position.dy - ty),
      ),
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _viewport = constraints.biggest;
        _layout = computeOrgLayout(
          root: widget.root,
          expandedIds: widget.expandedIds,
          highlightIds: widget.matchedIds,
        );

        if (!_didInitialFit && _layout.size != Size.zero) {
          _didInitialFit = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _fitToScreen(animate: false);
          });
        }

        if (widget.root == null) return const _EmptyChart();

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onDoubleTapDown: (details) => _lastDoubleTap = details,
                onDoubleTap: _handleDoubleTap,
                child: InteractiveViewer(
                  transformationController: _transform,
                  constrained: false,
                  minScale: _minScale,
                  maxScale: _maxScale,
                  boundaryMargin: const EdgeInsets.all(600),
                  child: SizedBox(
                    width: _layout.size.width,
                    height: _layout.size.height,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AnimatedBuilder(
                          animation: _drawController,
                          builder: (context, _) => CustomPaint(
                            size: _layout.size,
                            painter: ConnectorPainter(
                              edges: _layout.edges,
                              progress: Curves.easeOutCubic
                                  .transform(_drawController.value),
                            ),
                          ),
                        ),
                        for (var i = 0; i < _layout.nodes.length; i++)
                          _positionedNode(_layout.nodes[i], i),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(right: 14, bottom: 20, child: _zoomControls()),
          ],
        );
      },
    );
  }

  Widget _positionedNode(PositionedNode positioned, int index) {
    final employee = positioned.node.employee;
    final isMatch = widget.matchedIds.contains(positioned.id);

    return AnimatedPositioned(
      key: ValueKey(positioned.id),
      duration: DirMotion.base,
      curve: DirMotion.settle,
      left: positioned.topLeft.dx,
      top: positioned.topLeft.dy,
      child: AppearOnce(
        index: math.min(index, 12),
        child: OrgNodeCard(
          employee: employee,
          department: widget.departmentOf(employee.departmentId),
          company: widget.companyOf(employee.companyId),
          directReports: positioned.node.directReports,
          expanded: positioned.expanded,
          isSelected: widget.selectedId == positioned.id,
          isMatch: widget.isFiltering && isMatch,
          isDimmed: widget.isFiltering && !isMatch,
          onTap: () => widget.onOpen(positioned.id),
          onToggle: () => widget.onToggle(positioned.id),
          onLongPress: () => widget.onQuickActions(positioned.id),
        ),
      ),
    );
  }

  Widget _zoomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      decoration: BoxDecoration(
        color: DirColors.surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: DirColors.hairline),
        boxShadow: DirShadows.lifted(),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _controlButton(
            icon: Icons.add_rounded,
            tooltip: 'Zoom in',
            enabled: _scale < _maxScale - 0.01,
            onTap: () => _zoomBy(1.3),
          ),
          GestureDetector(
            onTap: () => _fitToScreen(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                '${(_scale * 100).round()}%',
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: DirColors.inkBody,
                ),
              ),
            ),
          ),
          _controlButton(
            icon: Icons.remove_rounded,
            tooltip: 'Zoom out',
            enabled: _scale > _minScale + 0.01,
            onTap: () => _zoomBy(1 / 1.3),
          ),
          Container(
            width: 22,
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 4),
            color: DirColors.hairline,
          ),
          _controlButton(
            icon: Icons.fit_screen_rounded,
            tooltip: 'Fit to screen',
            enabled: true,
            onTap: () => _fitToScreen(),
          ),
        ],
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String tooltip,
    required bool enabled,
    required VoidCallback onTap,
  }) =>
      Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Icon(
              icon,
              size: 19,
              color: enabled ? DirColors.inkBody : DirColors.inkFaint,
            ),
          ),
        ),
      );
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.person_search_rounded,
              size: 40, color: DirColors.inkFaint),
          SizedBox(height: 14),
          Text(
            'Nobody matches these filters',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: DirColors.inkBody,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Clear a facet or search a different name.',
            style: TextStyle(fontSize: 12.5, color: DirColors.inkMuted),
          ),
        ],
      ),
    );
  }
}
