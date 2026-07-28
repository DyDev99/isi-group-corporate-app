import 'package:flutter/material.dart';
import 'package:isi_group_corporate_app/features/hr_assistant/presentation/pages/hr_ai_assistant_screen.dart';

class CompanyPoliciesScreen extends StatelessWidget {
  const CompanyPoliciesScreen({super.key});

  final List<PolicyItem> _policies = const [
    PolicyItem(
      title: "Field Sales Representative Code of Conduct",
      category: "Conduct",
      updated: "Jun 2026",
      readTime: "4 min read",
      content:
          "All sales representatives must maintain professional standards during client visits, accurately log visit GPS coordinates, and ensure product pricing matches official price books.",
    ),
    PolicyItem(
      title: "Data Protection & Encrypted Storage Rules",
      category: "Security",
      updated: "May 2026",
      readTime: "6 min read",
      content:
          "Sensitive customer PII must only reside in the encrypted Drift database. Plaintext caching of access tokens or customer financial records is strictly prohibited under architecture guidelines.",
    ),
    PolicyItem(
      title: "Travel & Expense Reimbursement Guidelines",
      category: "Finance",
      updated: "Mar 2026",
      readTime: "3 min read",
      content:
          "Fuel and lodging expenses incurred during rural route operations must be submitted within 5 business days with attached photo receipts.",
    ),
  ];

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
                      Text("Company Policies",
                          style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: titleColor)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _policies.length,
                    itemBuilder: (context, index) {
                      final item = _policies[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: borderColor)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          onTap: () =>
                              _showPolicyReaderModal(context, item, isDark),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.article_outlined,
                                color: Color(0xFF2563EB), size: 22),
                          ),
                          title: Text(item.title,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: titleColor)),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                                "${item.category} • ${item.updated} • ${item.readTime}",
                                style: const TextStyle(
                                    fontSize: 11, color: Color(0xFF64748B))),
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded,
                              color: Color(0xFF94A3B8)),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPolicyReaderModal(
      BuildContext context, PolicyItem policy, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
            Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF475569)
                            : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text(policy.title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A))),
            const SizedBox(height: 6),
            Text("Updated: ${policy.updated} • Category: ${policy.category}",
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
            const SizedBox(height: 16),
            Text(policy.content,
                style: TextStyle(
                    fontSize: 14,
                    height: 1.5,
                    color: isDark
                        ? const Color(0xFFCBD5E1)
                        : const Color(0xFF334155))),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Policy acknowledged")));
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: const Text("I Acknowledge & Understand",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
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

class PolicyItem {
  final String title;
  final String category;
  final String updated;
  final String readTime;
  final String content;

  const PolicyItem(
      {required this.title,
      required this.category,
      required this.updated,
      required this.readTime,
      required this.content});
}
