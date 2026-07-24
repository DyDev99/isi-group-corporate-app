import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/hr_tokens.dart';

/// Three dots with a travelling wave, plus a rotating status line so a slow
/// retrieval still reads as progress rather than a hang.
class TypingIndicator extends StatefulWidget {
  const TypingIndicator({super.key});

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: HrColors.surface,
        borderRadius: BorderRadius.circular(HrRadius.bubble),
        border: Border.all(color: HrColors.hairline),
        boxShadow: HrShadows.soft(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                final phase = (_controller.value * 2 * math.pi) - (index * 0.7);
                final lift = math.sin(phase).clamp(-1.0, 1.0).toDouble();
                return Padding(
                  padding: EdgeInsets.only(right: index == 2 ? 0 : 5),
                  child: Transform.translate(
                    offset: Offset(0, -3 * lift),
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.lerp(
                          HrColors.inkFaint,
                          HrColors.brand,
                          (lift + 1) / 2,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Reading the policies',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: HrColors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}
