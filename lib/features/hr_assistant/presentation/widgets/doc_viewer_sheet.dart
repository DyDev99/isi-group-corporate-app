import 'package:flutter/material.dart';

import '../../domain/entities/knowledge_doc.dart';
import '../theme/hr_tokens.dart';

/// Opens the cited document page in a zoomable viewer.
Future<void> showDocViewer(BuildContext context, KnowledgeDoc doc) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: HrColors.ink.withValues(alpha: 0.45),
    builder: (_) => DocViewerSheet(doc: doc),
  );
}

/// The evidence view: the exact passage behind an answer, on a page you can
/// pinch, double-tap or button-zoom from 60% to 500%.
class DocViewerSheet extends StatefulWidget {
  final KnowledgeDoc doc;

  const DocViewerSheet({super.key, required this.doc});

  @override
  State<DocViewerSheet> createState() => _DocViewerSheetState();
}

class _DocViewerSheetState extends State<DocViewerSheet>
    with SingleTickerProviderStateMixin {
  static const double _minScale = 0.6;
  static const double _maxScale = 5.0;
  static const double _pageWidth = 560;

  final TransformationController _transform = TransformationController();
  late final AnimationController _zoomController = AnimationController(
    vsync: this,
    duration: HrMotion.base,
  );

  Animation<Matrix4>? _zoomAnimation;
  double _scale = 1;
  TapDownDetails? _lastDoubleTap;
  Size _viewport = Size.zero;

  @override
  void initState() {
    super.initState();
    _transform.addListener(_syncScale);
    _zoomController.addListener(() {
      final value = _zoomAnimation?.value;
      if (value != null) _transform.value = value;
    });
  }

  void _syncScale() {
    final next = _transform.value.getMaxScaleOnAxis();
    if ((next - _scale).abs() > 0.01) {
      setState(() => _scale = next);
    }
  }

  @override
  void dispose() {
    _transform.removeListener(_syncScale);
    _transform.dispose();
    _zoomController.dispose();
    super.dispose();
  }

  void _animateTo(Matrix4 target) {
    _zoomAnimation = Matrix4Tween(begin: _transform.value, end: target)
        .animate(CurvedAnimation(parent: _zoomController, curve: HrMotion.enter));
    _zoomController.forward(from: 0);
  }

  /// Scales around the centre of the viewport, so the passage the reader is
  /// looking at stays under their eyes instead of flying to the corner.
  void _zoomBy(double factor) {
    final current = _transform.value;
    final scale = current.getMaxScaleOnAxis();
    final next = (scale * factor).clamp(_minScale, _maxScale).toDouble();
    final ratio = next / scale;

    final tx = current.storage[12];
    final ty = current.storage[13];
    final cx = _viewport.width / 2;
    final cy = _viewport.height / 2;

    final target = Matrix4.identity()
      ..translate(cx - ratio * (cx - tx), cy - ratio * (cy - ty))
      ..scale(next);
    _animateTo(target);
  }

  void _reset() => _animateTo(Matrix4.identity());

  void _handleDoubleTap() {
    if (_scale > 1.4) {
      _reset();
      return;
    }
    final position = _lastDoubleTap?.localPosition;
    if (position == null) {
      _zoomBy(2.2);
      return;
    }
    const target = 2.4;
    final zoomed = Matrix4.identity()
      ..translate(-position.dx * (target - 1), -position.dy * (target - 1))
      ..scale(target);
    _animateTo(zoomed);
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.doc;

    return FractionallySizedBox(
      heightFactor: 0.94,
      child: Container(
        decoration: const BoxDecoration(
          color: HrColors.canvas,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(HrRadius.sheet),
          ),
        ),
        child: Column(
          children: [
            _grabber(),
            _header(context, doc),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  _viewport = constraints.biggest;
                  return Stack(
                children: [
                  Positioned.fill(
                    child: ClipRect(
                      child: GestureDetector(
                        onDoubleTapDown: (details) => _lastDoubleTap = details,
                        onDoubleTap: _handleDoubleTap,
                        child: InteractiveViewer(
                          transformationController: _transform,
                          minScale: _minScale,
                          maxScale: _maxScale,
                          constrained: false,
                          boundaryMargin: const EdgeInsets.all(120),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: SizedBox(
                              width: _pageWidth,
                              child: _DocumentPage(doc: doc),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(right: 16, bottom: 20, child: _zoomControls()),
                ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _grabber() => Container(
        margin: const EdgeInsets.only(top: 10, bottom: 6),
        width: 42,
        height: 4,
        decoration: BoxDecoration(
          color: HrColors.hairline,
          borderRadius: BorderRadius.circular(2),
        ),
      );

  Widget _header(BuildContext context, KnowledgeDoc doc) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 6, 12, 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: HrColors.brandWash,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.description_rounded,
                  color: HrColors.brand, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: HrColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${doc.code} · ${doc.version} · page ${doc.citedPage} of ${doc.pageCount}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: HrColors.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded, color: HrColors.inkMuted),
            ),
          ],
        ),
      );

  Widget _zoomControls() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        decoration: BoxDecoration(
          color: HrColors.surface,
          borderRadius: BorderRadius.circular(HrRadius.chip),
          border: Border.all(color: HrColors.hairline),
          boxShadow: HrShadows.lifted(),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _zoomButton(
              icon: Icons.remove_rounded,
              tooltip: 'Zoom out',
              enabled: _scale > _minScale + 0.01,
              onTap: () => _zoomBy(1 / 1.35),
            ),
            GestureDetector(
              onTap: _reset,
              child: Container(
                width: 56,
                alignment: Alignment.center,
                child: Text(
                  '${(_scale * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: HrColors.inkBody,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
            _zoomButton(
              icon: Icons.add_rounded,
              tooltip: 'Zoom in',
              enabled: _scale < _maxScale - 0.01,
              onTap: () => _zoomBy(1.35),
            ),
          ],
        ),
      );

  Widget _zoomButton({
    required IconData icon,
    required String tooltip,
    required bool enabled,
    required VoidCallback onTap,
  }) =>
      Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 20,
              color: enabled ? HrColors.inkBody : HrColors.inkFaint,
            ),
          ),
        ),
      );
}

/// The rendered "paper" — mock data stands in for the real PDF page until the
/// document service ships.
class _DocumentPage extends StatelessWidget {
  final KnowledgeDoc doc;

  const _DocumentPage({required this.doc});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(34, 34, 34, 28),
      decoration: BoxDecoration(
        color: HrColors.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: HrShadows.lifted(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                doc.code,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: HrColors.brand,
                ),
              ),
              Text(
                'ISI GROUP · ${doc.owner.toUpperCase()}',
                style: const TextStyle(
                  fontSize: 9.5,
                  letterSpacing: 1,
                  color: HrColors.inkFaint,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            doc.title,
            style: const TextStyle(
              fontSize: 24,
              height: 1.15,
              fontWeight: FontWeight.w800,
              color: HrColors.ink,
            ),
          ),
          const SizedBox(height: 10),
          Container(height: 2, width: 54, color: HrColors.brand),
          const SizedBox(height: 22),
          for (final paragraph in doc.excerpt) ...[
            _Paragraph(paragraph: paragraph),
            const SizedBox(height: 18),
          ],
          const SizedBox(height: 6),
          Container(height: 1, color: HrColors.surfaceMuted),
          const SizedBox(height: 10),
          Text(
            'Page ${doc.citedPage} of ${doc.pageCount} · ${doc.version} · effective ${_formatDate(doc.updatedAt)}',
            style: const TextStyle(fontSize: 10, color: HrColors.inkFaint),
          ),
        ],
      ),
    );
  }
}

class _Paragraph extends StatelessWidget {
  final DocParagraph paragraph;

  const _Paragraph({required this.paragraph});

  @override
  Widget build(BuildContext context) {
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (paragraph.heading != null) ...[
          Text(
            paragraph.heading!,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: HrColors.ink,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Text(
          paragraph.body,
          style: const TextStyle(
            fontSize: 13,
            height: 1.7,
            color: HrColors.inkBody,
          ),
        ),
      ],
    );

    if (!paragraph.cited) return body;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
      decoration: BoxDecoration(
        color: HrColors.cite.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          left: BorderSide(color: HrColors.warn, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.format_quote_rounded, size: 14, color: HrColors.warn),
              SizedBox(width: 5),
              Text(
                'PASSAGE USED IN THE ANSWER',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: HrColors.warn,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          body,
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}
