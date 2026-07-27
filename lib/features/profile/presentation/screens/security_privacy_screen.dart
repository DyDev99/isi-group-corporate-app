import 'package:flutter/material.dart';
import 'package:isi_group_corporate_app/features/hr_assistant/presentation/pages/hr_ai_assistant_screen.dart';

class SecurityPrivacyScreen extends StatefulWidget {
  const SecurityPrivacyScreen({super.key});

  @override
  State<SecurityPrivacyScreen> createState() => _SecurityPrivacyScreenState();
}

class _SecurityPrivacyScreenState extends State<SecurityPrivacyScreen> {
  bool _biometricsEnabled = true;
  bool _sqlCipherEncryption = true;
  bool _autoLockApp = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

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
                      Text("Security & Privacy", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: titleColor)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Container(
                    decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(20), border: Border.all(color: borderColor)),
                    child: Column(
                      children: [
                        SwitchListTile(
                          value: _biometricsEnabled,
                          activeThumbColor: const Color(0xFF2563EB),
                          title: Text("Biometric Lock (FaceID / TouchID)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: titleColor)),
                          subtitle: const Text("Require biometric unlock on app open", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          onChanged: (val) => setState(() => _biometricsEnabled = val),
                        ),
                        Divider(height: 1, color: borderColor),
                        SwitchListTile(
                          value: _sqlCipherEncryption,
                          activeThumbColor: const Color(0xFF2563EB),
                          title: Text("SQLCipher Offline DB Encryption", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: titleColor)),
                          subtitle: const Text("AES-256 key hardware-backed storage", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          onChanged: (val) => setState(() => _sqlCipherEncryption = val),
                        ),
                        Divider(height: 1, color: borderColor),
                        SwitchListTile(
                          value: _autoLockApp,
                          activeThumbColor: const Color(0xFF2563EB),
                          title: Text("Auto-Lock on Inactivity", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: titleColor)),
                          subtitle: const Text("Lock screen after 5 mins in background", style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                          onChanged: (val) => setState(() => _autoLockApp = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text("SECURITY AUDIT LOG", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B), letterSpacing: 0.8)),
                  const SizedBox(height: 12),

                  _buildAuditTile("Key Rotation Check", "Successful (0 errors)", "Today, 08:30 AM", isDark, cardBg, borderColor, titleColor),
                  _buildAuditTile("App Integrity Scan", "Passed (No Jailbreak detected)", "Yesterday, 18:45 PM", isDark, cardBg, borderColor, titleColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditTile(String title, String status, String time, bool isDark, Color bg, Color borderColor, Color titleColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: titleColor)),
              const SizedBox(height: 2),
              Text(status, style: const TextStyle(fontSize: 11, color: Color(0xFF059669), fontWeight: FontWeight.w600)),
            ],
          ),
          Text(time, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildBackButton(BuildContext context, bool isDark) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: isDark ? const Color(0xFF1E293B) : Colors.white, shape: BoxShape.circle, border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
      child: IconButton(icon: Icon(Icons.arrow_back_rounded, size: 20, color: isDark ? Colors.white : const Color(0xFF0F172A)), onPressed: () => Navigator.pop(context), padding: EdgeInsets.zero),
    );
  }
}