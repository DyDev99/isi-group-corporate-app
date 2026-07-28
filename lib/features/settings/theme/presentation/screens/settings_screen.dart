import 'package:flutter/material.dart';
import 'package:isi_group_corporate_app/features/hr_assistant/presentation/pages/hr_ai_assistant_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _syncInterval = '15 Minutes';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: CleanGridBackground()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildBackButton(context, isDark),
                      const SizedBox(width: 14),
                      Text("System Settings",
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: titleColor)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Border/radius on the outer box, fill on the Material:
                  // ListTile paints its ripple on the nearest Material, so a
                  // coloured intermediate box hides it and trips the
                  // "ink splashes may be invisible" assertion
                  // (`SKILL_GUIDE.md` §6 gotcha 2).
                  DecoratedBox(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderColor)),
                    child: Material(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(20),
                      clipBehavior: Clip.antiAlias,
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.sync_rounded,
                                color: Color(0xFF2563EB)),
                            title: Text("Sync Engine Interval",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: titleColor)),
                            subtitle: Text("Opportunistic sync: $_syncInterval",
                                style: const TextStyle(
                                    fontSize: 12, color: Color(0xFF64748B))),
                            trailing: const Icon(Icons.chevron_right_rounded,
                                color: Color(0xFF94A3B8)),
                            onTap: () => _showIntervalPicker(context, isDark),
                          ),
                          Divider(height: 1, color: borderColor),
                          ListTile(
                            leading: const Icon(Icons.storage_rounded,
                                color: Color(0xFF2563EB)),
                            title: Text("Local Drift DB Cache",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: titleColor)),
                            subtitle: const Text(
                                "14.2 MB encrypted database storage",
                                style: TextStyle(
                                    fontSize: 12, color: Color(0xFF64748B))),
                            trailing: TextButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            "Cache cleared successfully")));
                              },
                              child: const Text("Purge Cache",
                                  style: TextStyle(
                                      color: Color(0xFFE11D48),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Center(
                    child: Column(
                      children: const [
                        Text("ISI-GROUP-DEVELOPER",
                            style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF64748B))),
                        SizedBox(height: 2),
                        Text("Version 2026.1.0 (Build 482)",
                            style: TextStyle(
                                fontSize: 11, color: Color(0xFF94A3B8))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showIntervalPicker(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Sync Interval",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A))),
            const SizedBox(height: 12),
            ...['5 Minutes', '15 Minutes', '30 Minutes', 'Manual Only']
                .map((interval) {
              return RadioListTile<String>(
                title: Text(interval,
                    style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                        fontSize: 14)),
                value: interval,
                groupValue: _syncInterval,
                activeColor: const Color(0xFF2563EB),
                onChanged: (val) {
                  setState(() => _syncInterval = val!);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, bool isDark) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
              color:
                  isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
      child: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              size: 20, color: isDark ? Colors.white : const Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.zero),
    );
  }
}
