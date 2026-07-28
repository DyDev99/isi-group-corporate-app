import 'package:flutter/material.dart';
import 'package:isi_group_corporate_app/core/localization/localization_services.dart';
import 'package:isi_group_corporate_app/core/theme/theme_extensions.dart';

/// Rounded card wrapper for a group of settings rows.
///
/// ## The bug this widget exists to prevent
///
/// `ListTile` (and `SwitchListTile`) paint their background fill and ink
/// splash on the **nearest `Material` ancestor**, not on themselves. Putting a
/// background colour on an intermediate `Container`/`DecoratedBox` therefore
/// draws *over* those effects, and Flutter asserts:
///
/// > ListTile background color or ink splashes may be invisible.
///
/// The fix — and the whole point of this widget — is to split the decoration:
/// border, radius and shadow stay on the outer [DecoratedBox]; the **fill goes
/// on the [Material]**, which is then the tile's nearest ancestor and paints
/// the ripple correctly.
///
/// This is gotcha #2 in `SKILL_GUIDE.md` §6. Any settings-style card in this
/// feature should use this widget rather than re-deriving the pattern.
class SettingsCard extends StatelessWidget {
  const SettingsCard({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final radius = BorderRadius.circular(20);

    return DecoratedBox(
      // Border + shadow only — NO `color` here. See the class doc.
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: colors.border),
        boxShadow: colors.cardShadow,
      ),
      child: Material(
        // The fill lives here, so it is the tiles' nearest Material ancestor.
        color: colors.card,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: Column(children: children),
      ),
    );
  }
}

/// Uppercase section label above a [SettingsCard].
class SettingsSectionLabel extends StatelessWidget {
  const SettingsSectionLabel({
    super.key,
    required this.label,
    this.trailing,
    this.isLocalizationKey = true,
  });

  /// A localization key by default; pass [isLocalizationKey] false for copy
  /// that is already resolved or intentionally literal.
  final String label;
  final Widget? trailing;
  final bool isLocalizationKey;

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
        Expanded(
          child: Text(isLocalizationKey ? label.tr : label, style: style),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}
