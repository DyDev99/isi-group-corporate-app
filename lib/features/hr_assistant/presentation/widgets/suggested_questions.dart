import 'package:flutter/material.dart';

import '../theme/hr_tokens.dart';

/// Suggested openers for the current scope. Chips animate in on a stagger so
/// a scope change reads as a change, not a repaint.
class SuggestedQuestions extends StatelessWidget {
  final List<String> questions;
  final ValueChanged<String> onSelected;

  const SuggestedQuestions({
    super.key,
    required this.questions,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'TRY ASKING',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: HrColors.inkMuted,
              letterSpacing: 1.1,
            ),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: [
            for (var i = 0; i < questions.length; i++)
              _StaggeredChip(
                // Re-keyed per scope so the stagger replays on filter change.
                key: ValueKey('${questions[i]}_$i'),
                index: i,
                label: questions[i],
                onTap: () => onSelected(questions[i]),
              ),
          ],
        ),
      ],
    );
  }
}

class _StaggeredChip extends StatefulWidget {
  final int index;
  final String label;
  final VoidCallback onTap;

  const _StaggeredChip({
    super.key,
    required this.index,
    required this.label,
    required this.onTap,
  });

  @override
  State<_StaggeredChip> createState() => _StaggeredChipState();
}

class _StaggeredChipState extends State<_StaggeredChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: HrMotion.slow,
  );

  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _controller, curve: HrMotion.enter);

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.35),
          end: Offset.zero,
        ).animate(curved),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _pressed ? 0.96 : 1,
            duration: HrMotion.fast,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: HrColors.surface,
                borderRadius: BorderRadius.circular(HrRadius.chip),
                border: Border.all(color: HrColors.hairline),
                boxShadow: HrShadows.soft(),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.north_east_rounded,
                      size: 14, color: HrColors.brand),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 240),
                    child: Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: HrColors.inkBody,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
