import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:isi_group_corporate_app/core/localization/localization_services.dart';
import 'package:isi_group_corporate_app/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:isi_group_corporate_app/features/authentication/presentation/bloc/auth_event.dart';
import 'package:isi_group_corporate_app/features/digital_docs/presentation/screens/digital_docs_screen.dart';
import 'package:isi_group_corporate_app/features/profile/presentation/widgets/settings_card.dart';
import 'package:isi_group_corporate_app/features/performance/presentation/screens/performance_screen.dart';
import 'package:isi_group_corporate_app/features/profile/presentation/screens/company_policies_screen.dart';
import 'package:isi_group_corporate_app/features/profile/presentation/screens/payroll_payslip_screen.dart';
import 'package:isi_group_corporate_app/features/profile/presentation/screens/password_security_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isDarkMode = false;

  static const String _profileImageUrl =
      "https://i1.sndcdn.com/artworks-mGaisx4NJarpEeDh-NorasQ-t500x500.jpg";

  void _openFullScreenViewer(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: true,
        pageBuilder: (BuildContext context, _, __) {
          return FullScreenImageViewer(imageUrl: imageUrl);
        },
      ),
    );
  }

  /// Signs the user out through [AuthBloc].
  ///
  /// Confirmed first, because signing out is destructive to in-flight work and
  /// the button sits directly under the settings list.
  ///
  /// **Signing out clears tokens only.** Biometric registration lives in its
  /// own secure-storage keys that the auth data source never touches, so
  /// fingerprint / Face ID stays set up and the next sign-in offers it
  /// immediately — no repeat onboarding.
  ///
  /// No navigation happens here: `AuthBloc` emits `AuthGuestState`, the app
  /// stays open and browsable as a guest, and each surface owns its own
  /// transition (`ENGINEERING_STANDARD.md` §4 — no global auth redirect).
  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('profile.logout_confirm_title'.tr),
        content: Text('profile.logout_confirm_body'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('common.cancel'.tr),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
            ),
            child: Text('profile.logout'.tr),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;
    context.read<AuthBloc>().add(const LogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Subtle Grid Pattern Background Layer
          const Positioned.fill(
            child: CleanGridBackground(),
          ),

          // 2. Main Content Layer
          SafeArea(
            child: SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Top Action Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Profile",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      Row(
                        children: [
                          _buildHeaderIconButton(
                            icon: isDarkMode
                                ? Icons.wb_sunny_outlined
                                : Icons.nightlight_outlined,
                            onTap: () {
                              setState(() {
                                isDarkMode = !isDarkMode;
                              });
                            },
                          ),
                          const SizedBox(width: 10),

                          // Settings Popover Menu Button
                          PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            // Positioned directly under the settings icon (-140px left alignment)
                            offset: const Offset(50, 46),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            color: Colors.white,
                            elevation: 8,
                            shadowColor:
                                const Color(0xFF0F172A).withValues(alpha: 0.12),
                            onSelected: (String value) {
                              switch (value) {
                                case 'profile_detail':
                                  // TODO: Handle View Profile Detail
                                  break;
                                case 'security':
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const SecurityPrivacyScreen(),
                                    ),
                                  );
                                  break;
                                case 'appearance':
                                  // TODO: Handle Appearance
                                  break;
                              }
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                              _buildSettingsMenuItem(
                                value: 'profile_detail',
                                icon: Icons.person_outline_rounded,
                                title: 'View Profile Detail',
                              ),
                              const PopupMenuDivider(height: 1),
                              _buildSettingsMenuItem(
                                value: 'security',
                                icon: Icons.lock_outline_rounded,
                                title: 'Password and Security',
                              ),
                              const PopupMenuDivider(height: 1),
                              _buildSettingsMenuItem(
                                value: 'appearance',
                                icon: Icons.display_settings_outlined,
                                title: 'Appearance',
                              ),
                            ],
                            child: _buildHeaderIconContainer(
                                Icons.settings_outlined),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Avatar Profile Image Stack
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Clickable Avatar with Full Screen Zoom View
                      GestureDetector(
                        onTap: () =>
                            _openFullScreenViewer(context, _profileImageUrl),
                        child: Hero(
                          tag: 'profile_avatar',
                          child: Container(
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFF1E293B),
                              border: Border.all(color: Colors.white, width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0F172A)
                                      .withValues(alpha: 0.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                )
                              ],
                              image: const DecorationImage(
                                image: NetworkImage(_profileImageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Camera Popover Button anchored directly UNDER the camera icon
                      Positioned(
                        bottom: 0,
                        right: -2,
                        child: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          offset: const Offset(-90, 38),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          color: Colors.white,
                          elevation: 8,
                          shadowColor:
                              const Color(0xFF0F172A).withValues(alpha: 0.12),
                          onSelected: (String value) {
                            if (value == 'selfie') {
                              // TODO: Trigger camera selfie logic
                            } else if (value == 'upload') {
                              // TODO: Trigger gallery upload logic
                            }
                          },
                          itemBuilder: (BuildContext context) =>
                              <PopupMenuEntry<String>>[
                            PopupMenuItem<String>(
                              value: 'selfie',
                              height: 40,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.camera_alt_outlined,
                                    size: 18,
                                    color: Color(0xFF2563EB),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Take Selfie",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuDivider(height: 1),
                            PopupMenuItem<String>(
                              value: 'upload',
                              height: 40,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 14),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.photo_library_outlined,
                                    size: 18,
                                    color: Color(0xFF2563EB),
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    "Upload Photo",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 2.5),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0F172A)
                                      .withValues(alpha: 0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // User Name & Role
                  const Text(
                    "Sarah Jenkins",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Senior Marketing Manager",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Status & Employee ID Badges
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Active Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFA7F3D0)),
                        ),
                        child: const Text(
                          "Active",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF059669),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Employee ID Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Text(
                          "Employee ID: 88421",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Section: EMPLOYMENT
                  _buildSectionHeader("EMPLOYMENT"),
                  const SizedBox(height: 8),
                  SettingsCard(
                    children: [
                      _buildListTile(
                        icon: Icons.account_balance_outlined,
                        title: "Payroll & Payslips",
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const PayrollPayslipScreen(),
                            ),
                          );
                        },
                        showBorder: true,
                      ),
                      _buildListTile(
                        icon: Icons.description_outlined,
                        title: "Contracts & Documents",
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const DigitalDocsScreen(),
                            ),
                          );
                        },
                        showBorder: true,
                      ),
                      _buildListTile(
                        icon: Icons.workspace_premium_outlined,
                        title: "Performance & Goals",
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const PerformanceScreen(),
                            ),
                          );
                        },
                        showBorder: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Section: SYSTEM
                  _buildSectionHeader("SYSTEM"),
                  const SizedBox(height: 8),
                  SettingsCard(
                    children: [
                      _buildListTile(
                        icon: Icons.article_outlined,
                        title: "Company Policies",
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const CompanyPoliciesScreen(),
                            ),
                          );
                        },
                        showBorder: true,
                      ),
                      _buildListTile(
                        icon: Icons.shield_outlined,
                        title: "Password & Security",
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SecurityPrivacyScreen(),
                            ),
                          );
                        },
                        showBorder: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Sign Out Button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _confirmSignOut,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: const Color(0xFFFFF1F2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(color: Color(0xFFFFE4E6)),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.logout_rounded,
                            size: 18,
                            color: Color(0xFFE11D48),
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Sign Out",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFE11D48),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<String> _buildSettingsMenuItem({
    required String value,
    required IconData icon,
    required String title,
  }) {
    return PopupMenuItem<String>(
      value: value,
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: const Color(0xFF2563EB),
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIconContainer(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Icon(icon, size: 20, color: const Color(0xFF475569)),
    );
  }

  Widget _buildHeaderIconButton(
      {required IconData icon, required VoidCallback onTap}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: const Color(0xFF475569)),
        onPressed: onTap,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF64748B),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool showBorder,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: showBorder
            ? const Border(bottom: BorderSide(color: Color(0xFFF1F5F9)))
            : null,
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(
            color: Color(0xFFEFF6FF),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF2563EB)),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
        ),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          size: 20,
          color: Color(0xFF94A3B8),
        ),
      ),
    );
  }
}

// ============================================================================
// FULL SCREEN ZOOMABLE IMAGE VIEWER
// ============================================================================

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageViewer({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.8,
          maxScale: 4.0,
          child: Hero(
            tag: 'profile_avatar',
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// CLEAN GRID BACKGROUND PATTERN
// ============================================================================

class CleanGridBackground extends StatelessWidget {
  const CleanGridBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GridPatternPainter(),
      child: Container(),
    );
  }
}

class GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(const Color(0xFFF6F8FA), BlendMode.srcOver);

    final Paint linePaint = Paint()
      ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.6)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const double gridSize = 24.0;

    for (double x = 0; x <= size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }

    for (double y = 0; y <= size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
