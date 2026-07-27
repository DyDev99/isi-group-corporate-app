import 'package:flutter/material.dart';

/// Fades, lifts and scales a child in once, after an optional stagger delay.
///
/// Lives in `shared/widgets/` because more than one feature needs it — a
/// feature importing another feature's widgets would break the import boundary
/// in ENGINEERING_STANDARD §3.
class AppearOnce extends StatefulWidget {
  final Widget child;

  /// Position in a staggered group. Each step delays the start by [stagger].
  final int index;

  final Duration duration;
  final Duration stagger;
  final Offset slideFrom;
  final double scaleFrom;

  const AppearOnce({
    super.key,
    required this.child,
    this.index = 0,
    this.duration = const Duration(milliseconds: 460),
    this.stagger = const Duration(milliseconds: 55),
    this.slideFrom = const Offset(0, 0.08),
    this.scaleFrom = 0.97,
  });

  @override
  State<AppearOnce> createState() => _AppearOnceState();
}

class _AppearOnceState extends State<AppearOnce>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );

  @override
  void initState() {
    super.initState();
    final delay = widget.stagger * widget.index;
    if (delay == Duration.zero) {
      _controller.forward();
    } else {
      Future<void>.delayed(delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(begin: widget.slideFrom, end: Offset.zero)
            .animate(curved),
        child: ScaleTransition(
          scale: Tween<double>(begin: widget.scaleFrom, end: 1).animate(curved),
          child: widget.child,
        ),
      ),
    );
  }
}
