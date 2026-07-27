import 'package:flutter/material.dart';
import 'package:isi_group_corporate_app/core/localization/localization_services.dart';
import 'package:isi_group_corporate_app/core/theme/theme_extensions.dart';

/// A security switch whose ON position is owned by persisted state, never by
/// local widget state.
///
/// The distinction matters: the original screen held `bool _fingerprintEnabled`
/// in `setState`, so the switch moved the instant it was tapped and the app
/// looked enabled before anything had been verified. Here [value] is passed in
/// from the bloc, and [onChanged] only *requests* a change — the switch cannot
/// move until the persisted value comes back changed.
///
/// All colours resolve from `ColorScheme`/[AppThemeColors]; nothing is
/// hardcoded, so light and dark both track the theme.
class BiometricSwitchTile extends StatelessWidget {
  const BiometricSwitchTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.unavailableNote,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;

  /// Requests a change. Null disables the control.
  final ValueChanged<bool>? onChanged;

  final bool enabled;

  /// Shown under the subtitle when the device cannot offer this modality —
  /// an explanation instead of a silently dead switch.
  final String? unavailableNote;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final textTheme = Theme.of(context).textTheme;

    return SwitchListTile(
      value: value,
      onChanged: enabled ? onChanged : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: enabled ? iconColor : colors.textDisabled,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: enabled ? colors.textPrimary : colors.textDisabled,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: textTheme.bodySmall?.copyWith(color: colors.textSecondary),
          ),
          if (unavailableNote != null) ...[
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 13, color: colors.warning),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    unavailableNote!,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.warning,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Section label above a settings card.
class SecuritySectionLabel extends StatelessWidget {
  const SecuritySectionLabel({super.key, required this.label, this.trailing});

  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w800,
          color: colors.textSecondary,
          letterSpacing: 0.8,
        );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label.tr, style: style)),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Rounded card wrapper for a group of settings tiles.
///
/// The fill sits on a [Material] rather than on the outer `DecoratedBox`,
/// because `ListTile`/`SwitchListTile` paint their ripple on the nearest
/// `Material` — colouring the intermediate box triggers the "ink may be
/// invisible" assertion (`SKILL_GUIDE.md` §6 gotcha 2).
class SecurityCard extends StatelessWidget {
  const SecurityCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.border),
        boxShadow: colors.cardShadow,
      ),
      child: Material(
        color: colors.card,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
    );
  }
}
