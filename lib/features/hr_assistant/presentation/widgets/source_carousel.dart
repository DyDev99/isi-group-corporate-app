import 'package:flutter/material.dart';

import '../../domain/entities/knowledge_doc.dart';
import '../theme/hr_tokens.dart';
import 'doc_viewer_sheet.dart';

/// The signature element: every answer carries the documents it was built
/// from. Swipe left/right through them; tap one to open the cited page in the
/// zoomable viewer.
class SourceCarousel extends StatefulWidget {
  final List<KnowledgeDoc> sources;

  const SourceCarousel({super.key, required this.sources});

  @override
  State<SourceCarousel> createState() => _SourceCarouselState();
}

class _SourceCarouselState extends State<SourceCarousel> {
  late final PageController _controller =
      PageController(viewportFraction: 0.86);
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _page = _controller.page ?? 0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sources.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              const Icon(Icons.verified_rounded,
                  size: 13, color: HrColors.online),
              const SizedBox(width: 6),
              Text(
                widget.sources.length == 1
                    ? 'BASED ON 1 DOCUMENT'
                    : 'BASED ON ${widget.sources.length} DOCUMENTS · SWIPE',
                style: const TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: HrColors.inkMuted,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 132,
          child: PageView.builder(
            controller: _controller,
            physics: const BouncingScrollPhysics(),
            padEnds: false,
            itemCount: widget.sources.length,
            itemBuilder: (context, index) {
              final distance = (_page - index).abs().clamp(0.0, 1.0).toDouble();
              return Transform.scale(
                scale: 1 - (distance * 0.06),
                child: Opacity(
                  opacity: 1 - (distance * 0.25),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _SourceCard(
                      doc: widget.sources[index],
                      onTap: () => showDocViewer(context, widget.sources[index]),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        if (widget.sources.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 4),
            child: Row(
              children: [
                for (var i = 0; i < widget.sources.length; i++)
                  AnimatedContainer(
                    duration: HrMotion.fast,
                    margin: const EdgeInsets.only(right: 5),
                    width: (_page.round() == i) ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: (_page.round() == i)
                          ? HrColors.brand
                          : HrColors.hairline,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SourceCard extends StatelessWidget {
  final KnowledgeDoc doc;
  final VoidCallback onTap;

  const _SourceCard({required this.doc, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: HrColors.surface,
          borderRadius: BorderRadius.circular(HrRadius.card),
          border: Border.all(color: HrColors.hairline),
          boxShadow: HrShadows.soft(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(
                    color: HrColors.brandWash,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    doc.code,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: HrColors.brand,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${(doc.relevance * 100).round()}% match',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: HrColors.online,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Text(
              doc.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.25,
                fontWeight: FontWeight.w700,
                color: HrColors.ink,
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: Text(
                doc.summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  height: 1.35,
                  color: HrColors.inkMuted,
                ),
              ),
            ),
            Row(
              children: [
                const Icon(Icons.zoom_in_rounded,
                    size: 14, color: HrColors.brand),
                const SizedBox(width: 5),
                Text(
                  'Open page ${doc.citedPage}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: HrColors.brand,
                  ),
                ),
                const Spacer(),
                Text(
                  doc.version,
                  style: const TextStyle(
                    fontSize: 10,
                    color: HrColors.inkFaint,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
