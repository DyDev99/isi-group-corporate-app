import 'package:flutter/material.dart';

import '../../domain/entities/employee.dart';
import '../theme/directory_tokens.dart';
import 'employee_avatar.dart';

/// Appears while a filter or search is active. Swiping left/right through the
/// hits pans the chart to each person, so results and chart stay in step.
class MatchCarousel extends StatefulWidget {
  final List<Employee> matches;
  final Department? Function(String departmentId) departmentOf;
  final ValueChanged<String> onFocus;
  final ValueChanged<String> onOpen;

  const MatchCarousel({
    super.key,
    required this.matches,
    required this.departmentOf,
    required this.onFocus,
    required this.onOpen,
  });

  @override
  State<MatchCarousel> createState() => _MatchCarouselState();
}

class _MatchCarouselState extends State<MatchCarousel> {
  late final PageController _controller =
      PageController(viewportFraction: 0.82);
  double _page = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() => _page = _controller.page ?? 0);
    });
  }

  @override
  void didUpdateWidget(covariant MatchCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A new result set starts from the first hit.
    if (widget.matches.length != oldWidget.matches.length &&
        _controller.hasClients) {
      _controller.jumpToPage(0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.matches.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 92,
      child: PageView.builder(
        controller: _controller,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) => widget.onFocus(widget.matches[index].id),
        itemCount: widget.matches.length,
        itemBuilder: (context, index) {
          final employee = widget.matches[index];
          final accent = DirColors.accent(
            widget.departmentOf(employee.departmentId)?.accent ?? 1,
          );
          final distance = (_page - index).abs().clamp(0.0, 1.0).toDouble();

          return Transform.scale(
            scale: 1 - (distance * 0.07),
            child: Opacity(
              opacity: 1 - (distance * 0.35),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 6, 8, 10),
                child: GestureDetector(
                  onTap: () => widget.onOpen(employee.id),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: DirColors.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: DirColors.hairline),
                      boxShadow: DirShadows.lifted(),
                    ),
                    child: Row(
                      children: [
                        EmployeeAvatar(
                          employee: employee,
                          accent: accent,
                          size: 40,
                          radius: 13,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                employee.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: DirColors.ink,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                employee.role,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: DirColors.inkMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${index + 1}/${widget.matches.length}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: DirColors.inkFaint,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Icon(Icons.my_location_rounded,
                                size: 15, color: DirColors.brand),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
