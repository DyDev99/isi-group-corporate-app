import 'package:flutter/material.dart';

// ============================================================================
// PAYROLL & PAYSLIP FEATURE SCREEN
// ============================================================================

class PayrollPayslipScreen extends StatefulWidget {
  const PayrollPayslipScreen({super.key});

  @override
  State<PayrollPayslipScreen> createState() => _PayrollPayslipScreenState();
}

class _PayrollPayslipScreenState extends State<PayrollPayslipScreen>
    with SingleTickerProviderStateMixin {
  int _selectedYear = 2026;
  String _activeTab = 'All'; // 'All', 'Paid', 'Processing'
  late AnimationController _animationController;

  final List<int> _availableYears = [2026, 2025, 2024];

  // Mock domain data tailored for ISI Steel CRM Sales Reps
  final List<PayslipData> _allPayslips = [
    PayslipData(
      id: "PS-2026-07",
      month: "July 2026",
      payPeriod: "Jul 01, 2026 - Jul 31, 2026",
      payDate: "Jul 31, 2026",
      grossPay: 6200.00,
      netPay: 4850.00,
      baseSalary: 3500.00,
      commissionBonus: 2700.00,
      taxDeductions: 1050.00,
      socialSecurity: 300.00,
      status: "Processing",
      year: 2026,
    ),
    PayslipData(
      id: "PS-2026-06",
      month: "June 2026",
      payPeriod: "Jun 01, 2026 - Jun 30, 2026",
      payDate: "Jun 30, 2026",
      grossPay: 5900.00,
      netPay: 4620.00,
      baseSalary: 3500.00,
      commissionBonus: 2400.00,
      taxDeductions: 980.00,
      socialSecurity: 300.00,
      status: "Paid",
      year: 2026,
    ),
    PayslipData(
      id: "PS-2026-05",
      month: "May 2026",
      payPeriod: "May 01, 2026 - May 31, 2026",
      payDate: "May 31, 2026",
      grossPay: 5600.00,
      netPay: 4410.00,
      baseSalary: 3500.00,
      commissionBonus: 2100.00,
      taxDeductions: 890.00,
      socialSecurity: 300.00,
      status: "Paid",
      year: 2026,
    ),
    PayslipData(
      id: "PS-2026-04",
      month: "April 2026",
      payPeriod: "Apr 01, 2026 - Apr 30, 2026",
      payDate: "Apr 30, 2026",
      grossPay: 6300.00,
      netPay: 4890.00,
      baseSalary: 3500.00,
      commissionBonus: 2800.00,
      taxDeductions: 1110.00,
      socialSecurity: 300.00,
      status: "Paid",
      year: 2026,
    ),
    PayslipData(
      id: "PS-2025-12",
      month: "December 2025",
      payPeriod: "Dec 01, 2025 - Dec 31, 2025",
      payDate: "Dec 31, 2025",
      grossPay: 7100.00,
      netPay: 5520.00,
      baseSalary: 3500.00,
      commissionBonus: 3600.00,
      taxDeductions: 1280.00,
      socialSecurity: 300.00,
      status: "Paid",
      year: 2025,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  List<PayslipData> get _filteredPayslips {
    return _allPayslips.where((item) {
      final matchesYear = item.year == _selectedYear;
      if (_activeTab == 'Paid') return matchesYear && item.status == 'Paid';
      if (_activeTab == 'Processing') return matchesYear && item.status == 'Processing';
      return matchesYear;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: CleanGridBackground(isDark: isDark)),
          SafeArea(
            child: Column(
              children: [
                // Top App Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildIconButton(
                            icon: Icons.arrow_back_rounded,
                            isDark: isDark,
                            onTap: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            "Payroll & Payslips",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: titleColor,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      _buildYearSelector(isDark),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Glassmorphic Executive Salary Summary Card
                        _buildExecutiveSummaryCard(isDark),
                        const SizedBox(height: 24),

                        // Tab Filter Controls
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "PAYSLIP RECORDS",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                letterSpacing: 0.8,
                              ),
                            ),
                            _buildFilterSegmentedControl(isDark),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Animated Payslip List
                        _filteredPayslips.isEmpty
                            ? _buildEmptyState(isDark)
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _filteredPayslips.length,
                                itemBuilder: (context, index) {
                                  final payslip = _filteredPayslips[index];
                                  return _buildPayslipCard(
                                    context: context,
                                    payslip: payslip,
                                    cardBg: cardBg,
                                    borderColor: borderColor,
                                    titleColor: titleColor,
                                    isDark: isDark,
                                  );
                                },
                              ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Header Year Dropdown
  Widget _buildYearSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedYear,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF64748B)),
          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
          onChanged: (int? newValue) {
            if (newValue != null) {
              setState(() => _selectedYear = newValue);
            }
          },
          items: _availableYears.map<DropdownMenuItem<int>>((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Text("$value"),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Main Executive Summary Header
  Widget _buildExecutiveSummaryCard(bool isDark) {
    final ytdEarnings = _allPayslips
        .where((p) => p.year == _selectedYear)
        .fold(0.0, (sum, item) => sum + item.netPay);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF334155)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "$_selectedYear YTD NET EARNINGS",
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF059669).withValues(alpha: 0.4)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.verified_outlined, color: Color(0xFF34D399), size: 14),
                    SizedBox(width: 4),
                    Text(
                      "SAP Verified",
                      style: TextStyle(color: Color(0xFF34D399), fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "\$${ytdEarnings.toStringAsFixed(2)}",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.0,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SummaryStat(label: "Base Salary Tier", value: "\$3,500.00/mo"),
                _SummaryStat(label: "Commission Rate", value: "4.2% Fixed"),
                _SummaryStat(label: "Tax Status", value: "Standard W-2"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Filter Pills (All / Paid / Processing)
  Widget _buildFilterSegmentedControl(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: ['All', 'Paid', 'Processing'].map((tab) {
          final isSelected = _activeTab == tab;
          return GestureDetector(
            onTap: () => setState(() => _activeTab = tab),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? const Color(0xFF334155) : Colors.white)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                        )
                      ]
                    : [],
              ),
              child: Text(
                tab,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? (isDark ? Colors.white : const Color(0xFF0F172A))
                      : const Color(0xFF64748B),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // Individual Payslip Item Card
  Widget _buildPayslipCard({
    required BuildContext context,
    required PayslipData payslip,
    required Color cardBg,
    required Color borderColor,
    required Color titleColor,
    required bool isDark,
  }) {
    final isProcessing = payslip.status == 'Processing';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => _showPayslipDetailModal(context, payslip, isDark),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isProcessing
                            ? const Color(0xFFFFF7ED)
                            : (isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5)),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isProcessing ? Icons.pending_actions_rounded : Icons.receipt_long_rounded,
                        color: isProcessing ? const Color(0xFFEA580C) : const Color(0xFF059669),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            payslip.month,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: titleColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "Pay Date: ${payslip.payDate}",
                            style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "\$${payslip.netPay.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: titleColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isProcessing ? const Color(0xFFFFF7ED) : const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            payslip.status,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isProcessing ? const Color(0xFFEA580C) : const Color(0xFF059669),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(height: 1, color: isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Gross: \$${payslip.grossPay.toStringAsFixed(2)}  •  Tax: -\$${payslip.taxDeductions.toStringAsFixed(2)}",
                      style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                    Row(
                      children: const [
                        Text("View Breakdown", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                        SizedBox(width: 2),
                        Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF2563EB)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.folder_off_outlined, size: 48, color: isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
          const SizedBox(height: 12),
          Text(
            "No payslips found",
            style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF0F172A)),
          ),
          const SizedBox(height: 4),
          const Text(
            "There are no payroll records matching your active filter.",
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Bottom Sheet Modal: Detailed Payslip Breakdown
  void _showPayslipDetailModal(BuildContext context, PayslipData payslip, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        payslip.month,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        "Period: ${payslip.payPeriod}",
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      payslip.id,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Itemized Breakdown Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildBreakdownRow("Base Monthly Salary", "\$${payslip.baseSalary.toStringAsFixed(2)}", isDark, isBold: false),
                    const SizedBox(height: 10),
                    _buildBreakdownRow("Sales Commission & Bonus", "+\$${payslip.commissionBonus.toStringAsFixed(2)}", isDark, isBold: false, isPositive: true),
                    const SizedBox(height: 10),
                    _buildBreakdownRow("Income Tax Deductions", "-\$${payslip.taxDeductions.toStringAsFixed(2)}", isDark, isBold: false, isNegative: true),
                    const SizedBox(height: 10),
                    _buildBreakdownRow("Social Security / Benefits", "-\$${payslip.socialSecurity.toStringAsFixed(2)}", isDark, isBold: false, isNegative: true),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1),
                    ),
                    _buildBreakdownRow("Net Disbursed Amount", "\$${payslip.netPay.toStringAsFixed(2)}", isDark, isBold: true),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Sharing PDF for ${payslip.month}...")),
                        );
                      },
                      icon: const Icon(Icons.share_outlined, size: 18),
                      label: const Text("Share"),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Downloading official PDF for ${payslip.id}")),
                        );
                      },
                      icon: const Icon(Icons.file_download_outlined, size: 18, color: Colors.white),
                      label: const Text("Download PDF", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: const Color(0xFF2563EB),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBreakdownRow(String title, String amount, bool isDark, {bool isBold = false, bool isPositive = false, bool isNegative = false}) {
    Color amountColor = isDark ? Colors.white : const Color(0xFF0F172A);
    if (isPositive) amountColor = const Color(0xFF059669);
    if (isNegative) amountColor = const Color(0xFFE11D48);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isBold ? 14 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold
                ? (isDark ? Colors.white : const Color(0xFF0F172A))
                : const Color(0xFF64748B),
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isBold ? 16 : 13,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: amountColor,
          ),
        ),
      ],
    );
  }

  Widget _buildIconButton({required IconData icon, required bool isDark, required VoidCallback onTap}) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: IconButton(
        icon: Icon(icon, size: 20, color: isDark ? Colors.white : const Color(0xFF0F172A)),
        onPressed: onTap,
        padding: EdgeInsets.zero,
      ),
    );
  }
}

// Data Model
class PayslipData {
  final String id;
  final String month;
  final String payPeriod;
  final String payDate;
  final double grossPay;
  final double netPay;
  final double baseSalary;
  final double commissionBonus;
  final double taxDeductions;
  final double socialSecurity;
  final String status;
  final int year;

  PayslipData({
    required this.id,
    required this.month,
    required this.payPeriod,
    required this.payDate,
    required this.grossPay,
    required this.netPay,
    required this.baseSalary,
    required this.commissionBonus,
    required this.taxDeductions,
    required this.socialSecurity,
    required this.status,
    required this.year,
  });
}

// Shared Background Component
class CleanGridBackground extends StatelessWidget {
  final bool isDark;
  const CleanGridBackground({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GridPatternPainter(isDark: isDark),
      child: Container(),
    );
  }
}

class GridPatternPainter extends CustomPainter {
  final bool isDark;
  GridPatternPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final bgColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF6F8FA);
    final lineColor = isDark
        ? const Color(0xFF334155).withValues(alpha: 0.3)
        : const Color(0xFFE2E8F0).withValues(alpha: 0.6);

    canvas.drawColor(bgColor, BlendMode.srcOver);

    final Paint linePaint = Paint()
      ..color = lineColor
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
  bool shouldRepaint(covariant GridPatternPainter oldDelegate) => oldDelegate.isDark != isDark;
}

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }
}