import 'package:flutter/material.dart';
import 'package:isi_group_corporate_app/core/localization/localization_services.dart';
import 'package:isi_group_corporate_app/core/theme/theme_extensions.dart';

/// A staff-facing security policy document.
@immutable
class SecurityDocument {
  const SecurityDocument({
    required this.id,
    required this.titleKey,
    required this.categoryKey,
    required this.readTimeKey,
    required this.lastUpdated,
    required this.icon,
    required this.bodyKey,
  });

  final String id;
  final String titleKey;
  final String categoryKey;
  final String readTimeKey;
  final String lastUpdated;
  final IconData icon;
  final String bodyKey;
}

/// The knowledge-hub corpus.
///
/// Relocated verbatim from `password_security_screen.dart` (where it was inline
/// widget state) and moved onto localization keys so it renders in en and km.
///
/// TODO(release-gate): this is still demo content living in presentation.
/// It belongs in a profile datasource behind the repository per
/// `SKILL_GUIDE.md` §2.3 — out of scope for the biometric change, tracked here
/// so it is not mistaken for intentional.
const List<SecurityDocument> securityKnowledgeDocs = [
  SecurityDocument(
    id: 'DOC-SEC-01',
    titleKey: 'profile.security.docs.info_security.title',
    categoryKey: 'profile.security.docs.info_security.category',
    readTimeKey: 'profile.security.docs.info_security.read_time',
    lastUpdated: 'Jul 2026',
    icon: Icons.shield_outlined,
    bodyKey: 'profile.security.docs.info_security.body',
  ),
  SecurityDocument(
    id: 'DOC-PRIV-02',
    titleKey: 'profile.security.docs.privacy.title',
    categoryKey: 'profile.security.docs.privacy.category',
    readTimeKey: 'profile.security.docs.privacy.read_time',
    lastUpdated: 'Jun 2026',
    icon: Icons.privacy_tip_outlined,
    bodyKey: 'profile.security.docs.privacy.body',
  ),
  SecurityDocument(
    id: 'DOC-BIO-03',
    titleKey: 'profile.security.docs.biometric.title',
    categoryKey: 'profile.security.docs.biometric.category',
    readTimeKey: 'profile.security.docs.biometric.read_time',
    lastUpdated: 'May 2026',
    icon: Icons.fingerprint_rounded,
    bodyKey: 'profile.security.docs.biometric.body',
  ),
  SecurityDocument(
    id: 'DOC-MOB-04',
    titleKey: 'profile.security.docs.mobile.title',
    categoryKey: 'profile.security.docs.mobile.category',
    readTimeKey: 'profile.security.docs.mobile.read_time',
    lastUpdated: 'Apr 2026',
    icon: Icons.smartphone_rounded,
    bodyKey: 'profile.security.docs.mobile.body',
  ),
];

/// The knowledge-hub list.
class SecurityKnowledgeList extends StatelessWidget {
  const SecurityKnowledgeList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: securityKnowledgeDocs.length,
      itemBuilder: (context, index) =>
          _DocumentCard(doc: securityKnowledgeDocs[index]),
    );
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.doc});

  final SecurityDocument doc;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.border),
          boxShadow: colors.cardShadow,
        ),
        child: Material(
          color: colors.card,
          borderRadius: BorderRadius.circular(18),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _openReader(context, doc),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: colors.surfaceSoft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(doc.icon, color: scheme.primary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: scheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                doc.categoryKey.tr,
                                style: textTheme.labelSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: scheme.primary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                '• ${doc.readTimeKey.tr}',
                                overflow: TextOverflow.ellipsis,
                                style: textTheme.labelSmall
                                    ?.copyWith(color: colors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          doc.titleKey.tr,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.menu_book_rounded,
                      color: colors.iconMuted, size: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _openReader(BuildContext context, SecurityDocument doc) {
    final colors = context.appColors;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        height: MediaQuery.of(sheetContext).size.height * 0.8,
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetGrabber(),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.titleKey.tr,
                        style: Theme.of(sheetContext)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colors.textPrimary,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'profile.security.doc_meta'.trParams({
                          'id': doc.id,
                          'updated': doc.lastUpdated,
                        }),
                        style: Theme.of(sheetContext)
                            .textTheme
                            .labelSmall
                            ?.copyWith(color: colors.textSecondary),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  color: colors.textSecondary,
                  onPressed: () => Navigator.pop(sheetContext),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(height: 1, color: colors.divider),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surfaceSoft,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: colors.border),
                  ),
                  child: Text(
                    doc.bodyKey.tr,
                    style: Theme.of(sheetContext)
                        .textTheme
                        .bodySmall
                        ?.copyWith(height: 1.6, color: colors.textPrimary),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => Navigator.pop(sheetContext),
              icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
              label: Text('profile.security.acknowledge'.tr),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetGrabber extends StatelessWidget {
  const _SheetGrabber();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 38,
        height: 4,
        decoration: BoxDecoration(
          color: context.appColors.border,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

/// Change-password sheet.
///
/// TODO(release-gate): still presentation-only — it shows a confirmation
/// without calling the `ChangePassword` usecase that already exists in
/// `profile/domain/usecases/`. Pre-existing behaviour, preserved rather than
/// silently "fixed" inside a biometric change (`AI_ENGINEERING_PLAYBOOK.md` §8).
Future<void> showChangePasswordSheet(BuildContext context) {
  final colors = context.appColors;
  final currentPassword = TextEditingController();
  final newPassword = TextEditingController();
  final confirmPassword = TextEditingController();

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SheetGrabber(),
            const SizedBox(height: 18),
            Text(
              'profile.security.change_password'.tr,
              style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.textPrimary,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'profile.security.change_password_hint'.tr,
              style: Theme.of(sheetContext)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: colors.textSecondary),
            ),
            const SizedBox(height: 20),
            _PasswordField(
              label: 'profile.security.current_password'.tr,
              controller: currentPassword,
            ),
            const SizedBox(height: 12),
            _PasswordField(
              label: 'profile.security.new_password'.tr,
              controller: newPassword,
            ),
            const SizedBox(height: 12),
            _PasswordField(
              label: 'profile.security.confirm_new_password'.tr,
              controller: confirmPassword,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                Navigator.pop(sheetContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('profile.security.password_updated'.tr),
                  ),
                );
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text('profile.security.update_password'.tr),
            ),
          ],
        ),
      ),
    ),
  );
}

class _PasswordField extends StatelessWidget {
  const _PasswordField({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: colors.border),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.textSecondary,
              ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: true,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: colors.textPrimary),
          decoration: InputDecoration(
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: colors.surfaceSoft,
            border: border,
            enabledBorder: border,
          ),
        ),
      ],
    );
  }
}
