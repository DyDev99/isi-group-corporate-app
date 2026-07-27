import 'package:flutter/material.dart';
import 'package:isi_group_corporate_app/core/theme/theme_extensions.dart';

/// Shared chrome for every step of the biometric onboarding flow.
///
/// One place owns the layout contract so the five steps feel like one
/// continuous experience rather than five screens that happen to follow each
/// other: same icon treatment, same title/body rhythm, same button stack, same
/// safe-area and tablet behaviour.
///
/// Every colour comes from `ColorScheme` or [AppThemeColors] — no literals, so
/// light/dark and any future brand palette track automatically.
class BiometricScaffold extends StatelessWidget {
  const BiometricScaffold({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.iconColor,
    this.iconBackground,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
    this.isBusy = false,
    this.extra,
    this.showCloseButton = true,
    this.onClose,
  });

  final IconData icon;
  final String title;
  final String body;

  /// Defaults to `colorScheme.primary`.
  final Color? iconColor;
  final Color? iconBackground;

  final String? primaryLabel;
  final VoidCallback? onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  /// Disables both buttons and shows a spinner in the primary one.
  final bool isBusy;

  /// Optional content between the body copy and the buttons (bullet lists,
  /// step-by-step directions, a progress indicator).
  final Widget? extra;

  final bool showCloseButton;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;
    final resolvedIconColor = iconColor ?? scheme.primary;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Center(
          // Constrained so the flow reads as a centred column on tablets and
          // foldables instead of stretching text to the full width.
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (showCloseButton)
                    Align(
                      alignment: AlignmentDirectional.topEnd,
                      child: IconButton(
                        onPressed: isBusy ? null : onClose,
                        icon: const Icon(Icons.close_rounded),
                        color: colors.textSecondary,
                        tooltip: MaterialLocalizations.of(context)
                            .closeButtonTooltip,
                      ),
                    ),
                  _Badge(
                    icon: icon,
                    color: resolvedIconColor,
                    background: iconBackground ??
                        resolvedIconColor.withValues(alpha: 0.12),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: textTheme.headlineSmall?.copyWith(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    body,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  if (extra != null) ...[
                    const SizedBox(height: 24),
                    extra!,
                  ],
                  const SizedBox(height: 32),
                  if (primaryLabel != null)
                    FilledButton(
                      onPressed: isBusy ? null : onPrimary,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isBusy
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                                valueColor: AlwaysStoppedAnimation(
                                  scheme.onPrimary,
                                ),
                              ),
                            )
                          : Text(primaryLabel!),
                    ),
                  if (secondaryLabel != null) ...[
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: isBusy ? null : onSecondary,
                      style: TextButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: Text(
                        secondaryLabel!,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The circular icon badge, with a soft halo. Scales in once on appear —
/// subtle, not showy.
class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.85, end: 1),
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) =>
            Transform.scale(scale: scale, child: child),
        child: Container(
          width: 104,
          height: 104,
          decoration: BoxDecoration(color: background, shape: BoxShape.circle),
          child: Icon(icon, size: 52, color: color),
        ),
      ),
    );
  }
}

/// A single "what you get" bullet, used by the welcome step.
class BiometricBullet extends StatelessWidget {
  const BiometricBullet({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: scheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.textPrimary,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A numbered instruction row, used by the enrolment step's manual directions.
class BiometricInstruction extends StatelessWidget {
  const BiometricInstruction({
    super.key,
    required this.step,
    required this.label,
  });

  final int step;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$step',
              style: TextStyle(
                color: scheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.textSecondary,
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
