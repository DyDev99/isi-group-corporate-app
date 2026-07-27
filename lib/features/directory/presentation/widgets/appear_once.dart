import 'package:flutter/material.dart';

import '../theme/directory_tokens.dart';

/// Fades and scales a child in once, optionally after a stagger delay. Used
/// for nodes entering the chart and rows entering the list.
class AppearOnce extends StatefulWidget {
  final Widget child;
  final int index;
  final Offset slideFrom;

  const AppearOnce({
    super.key,
    required this.child,
    this.index = 0,
    this.slideFrom = const Offset(0, 0.06),
  });

  @override
  State<AppearOnce> createState() => _AppearOnceState();
}

class _AppearOnceState extends State<AppearOnce>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: DirMotion.slow,
  );

  @override
  void initState() {
    super.initState();
    final delay = Duration(milliseconds: 28 * widget.index);
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
    final curved =
        CurvedAnimation(parent: _controller, curve: DirMotion.settle);

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(begin: widget.slideFrom, end: Offset.zero)
            .animate(curved),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
          child: widget.child,
        ),
      ),
    );
  }
}
