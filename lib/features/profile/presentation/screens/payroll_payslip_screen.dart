import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:isi_group_corporate_app/core/security/biometric/authentication_reason.dart';
import 'package:isi_group_corporate_app/shared/widgets/biometric/sensitive_screen_guard.dart';

// ============================================================================
// PAYROLL & PAYSLIP FEATURE SCREEN FOR STAFF
// ============================================================================

/// Salary data — gated behind a fresh identity check.
///
/// The guard wraps the screen rather than each `Navigator.push`, so every
/// route into payslips (Profile menu, and any future entry point) passes
/// through it. The public class name is unchanged, so no call site moves.
class PayrollPayslipScreen extends StatelessWidget {
  const PayrollPayslipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SensitiveScreenGuard(
      reason: AuthenticationReason.confirmPayment,
      titleKey: 'profile.payroll.title',
      descriptionKey: 'auth.biometric.gate.payroll_body',
      child: _PayrollPayslipView(),
    );
  }
}

class _PayrollPayslipView extends StatefulWidget {
  const _PayrollPayslipView();

  @override
  State<_PayrollPayslipView> createState() => _PayrollPayslipScreenState();
}

class _PayrollPayslipScreenState extends State<_PayrollPayslipView>
    with SingleTickerProviderStateMixin {
  int _selectedYear = 2026;
  String _activeTab = 'All'; // 'All', 'Paid', 'Processing'
  bool _isAmountVisible = true; // Privacy toggle for salary hiding
  late AnimationController _animationController;

  final List<int> _availableYears = [2026, 2025, 2024];

  // Domain data tailored for staff payroll
  final List<PayslipData> _allPayslips = [
    PayslipData(
      id: "PS-2026-07",
      month: "July 2026",
      payPeriod: "Jul 01, 2026 - Jul 31, 2026",
      payDate: "Jul 31, 2026",
      grossPay: 6200.00,
      netPay: 4850.00,
      baseSalary: 3500.00,
      commissionBonus: 2200.00,
      allowances: 500.00,
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
      commissionBonus: 1900.00,
      allowances: 500.00,
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
      commissionBonus: 1600.00,
      allowances: 500.00,
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
      commissionBonus: 2300.00,
      allowances: 500.00,
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
      commissionBonus: 3100.00,
      allowances: 500.00,
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

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() {});
    }
  }

  List<PayslipData> get _filteredPayslips {
    return _allPayslips.where((item) {
      final matchesYear = item.year == _selectedYear;
      if (_activeTab == 'Paid') {
        return matchesYear && item.status == 'Paid';
      }
      if (_activeTab == 'Processing') {
        return matchesYear && item.status == 'Processing';
      }
      return matchesYear;
    }).toList();
  }

  String _formatAmount(double amount) {
    if (!_isAmountVisible) return "••••••••";
    return "\$${amount.toStringAsFixed(2)}";
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: titleColor, size: 18.sp),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Payroll & Payslips",
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _isAmountVisible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: const Color(0xFF64748B),
              size: 20.sp,
            ),
            tooltip: _isAmountVisible
                ? "Hide Salary Amounts"
                : "Show Salary Amounts",
            onPressed: () =>
                setState(() => _isAmountVisible = !_isAmountVisible),
          ),
          _buildYearSelector(isDark),
          SizedBox(width: 12.w),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        color: const Color(0xFF2563EB),
        backgroundColor: Colors.white,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          padding: EdgeInsets.all(20.r),
          children: [
            // Executive YTD Salary Header Card
            _buildExecutiveSummaryCard(isDark),
            SizedBox(height: 20.h),

            // Tab Filter Controls & Section Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "PAYSLIP RECORDS",
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? const Color(0xFF94A3B8)
                        : const Color(0xFF64748B),
                    letterSpacing: 0.8,
                  ),
                ),
                _buildFilterSegmentedControl(isDark),
              ],
            ),
            SizedBox(height: 14.h),

            // Payslips List
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
          ],
        ),
      ),
    );
  }

  // Header Year Dropdown
  Widget _buildYearSelector(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedYear,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              size: 16.sp, color: const Color(0xFF64748B)),
          dropdownColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
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

  // Executive Summary Card
  Widget _buildExecutiveSummaryCard(bool isDark) {
    final ytdEarnings = _allPayslips
        .where((p) => p.year == _selectedYear)
        .fold(0.0, (sum, item) => sum + item.netPay);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: const Color(0xFF334155)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
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
                style: TextStyle(
                  color: const Color(0xFF94A3B8),
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(
                      color: const Color(0xFF059669).withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.verified_outlined,
                        color: const Color(0xFF34D399), size: 12.sp),
                    SizedBox(width: 4.w),
                    Text(
                      "SAP Verified",
                      style: TextStyle(
                          color: const Color(0xFF34D399),
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            _formatAmount(ytdEarnings),
            style: TextStyle(
              color: Colors.white,
              fontSize: 30.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SummaryStat(
                    label: "Base Salary", value: _formatAmount(3500.00)),
                _SummaryStat(label: "Allowances", value: _formatAmount(500.00)),
                const _SummaryStat(label: "Tax Status", value: "Standard W-2"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Filter Segmented Control
  Widget _buildFilterSegmentedControl(bool isDark) {
    return Container(
      padding: EdgeInsets.all(3.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: ['All', 'Paid', 'Processing'].map((tab) {
          final isSelected = _activeTab == tab;
          return GestureDetector(
            onTap: () => setState(() => _activeTab = tab),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? const Color(0xFF334155) : Colors.white)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8.r),
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
                  fontSize: 10.5.sp,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
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

  // Individual Payslip Card
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
      margin: EdgeInsets.only(bottom: 12.h),
      child: _AnimatedPressable(
        onTap: () => _showPayslipDetailModal(context, payslip, isDark),
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 42.r,
                    height: 42.r,
                    decoration: BoxDecoration(
                      color: isProcessing
                          ? const Color(0xFFFFF7ED)
                          : (isDark
                              ? const Color(0xFF064E3B)
                              : const Color(0xFFECFDF5)),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isProcessing
                          ? Icons.pending_actions_rounded
                          : Icons.receipt_long_rounded,
                      color: isProcessing
                          ? const Color(0xFFEA580C)
                          : const Color(0xFF059669),
                      size: 20.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payslip.month,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14.sp,
                            color: titleColor,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          "Pay Date: ${payslip.payDate}",
                          style: TextStyle(
                              fontSize: 11.sp, color: const Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _formatAmount(payslip.netPay),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15.sp,
                          color: titleColor,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: isProcessing
                              ? const Color(0xFFFFF7ED)
                              : const Color(0xFFECFDF5),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          payslip.status,
                          style: TextStyle(
                            fontSize: 9.5.sp,
                            fontWeight: FontWeight.w800,
                            color: isProcessing
                                ? const Color(0xFFEA580C)
                                : const Color(0xFF059669),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Divider(
                  height: 1,
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFF1F5F9)),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Gross: ${_formatAmount(payslip.grossPay)}  •  Tax: -${_formatAmount(payslip.taxDeductions)}",
                    style: TextStyle(
                        fontSize: 10.5.sp, color: const Color(0xFF64748B)),
                  ),
                  Row(
                    children: [
                      Text("Breakdown",
                          style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF2563EB))),
                      SizedBox(width: 2.w),
                      Icon(Icons.chevron_right_rounded,
                          size: 16.sp, color: const Color(0xFF2563EB)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.r),
      child: Column(
        children: [
          Icon(Icons.folder_off_outlined,
              size: 44.sp,
              color:
                  isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1)),
          SizedBox(height: 12.h),
          Text(
            "No payslips found",
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
                color: isDark ? Colors.white : const Color(0xFF0F172A)),
          ),
          SizedBox(height: 4.h),
          Text(
            "There are no payroll records matching your active filter.",
            style: TextStyle(fontSize: 11.sp, color: const Color(0xFF64748B)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Detailed Payslip Modal Bottom Sheet
  void _showPayslipDetailModal(
      BuildContext context, PayslipData payslip, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF475569)
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),

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
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w800,
                          color:
                              isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        "Period: ${payslip.payPeriod}",
                        style: TextStyle(
                            fontSize: 11.sp, color: const Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      payslip.id,
                      style: TextStyle(
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF2563EB)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Earnings & Deductions Breakdown Box
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("EARNINGS",
                        style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF059669),
                            letterSpacing: 0.5)),
                    SizedBox(height: 8.h),
                    _buildBreakdownRow("Base Monthly Salary",
                        _formatAmount(payslip.baseSalary), isDark),
                    SizedBox(height: 8.h),
                    _buildBreakdownRow("Incentives & Bonus",
                        "+${_formatAmount(payslip.commissionBonus)}", isDark,
                        isPositive: true),
                    SizedBox(height: 8.h),
                    _buildBreakdownRow("Allowances (Phone & Transport)",
                        "+${_formatAmount(payslip.allowances)}", isDark,
                        isPositive: true),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      child: Divider(
                          height: 1,
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0)),
                    ),
                    Text("DEDUCTIONS",
                        style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFE11D48),
                            letterSpacing: 0.5)),
                    SizedBox(height: 8.h),
                    _buildBreakdownRow("Income Tax Deductions",
                        "-${_formatAmount(payslip.taxDeductions)}", isDark,
                        isNegative: true),
                    SizedBox(height: 8.h),
                    _buildBreakdownRow("Social Security / NSSF",
                        "-${_formatAmount(payslip.socialSecurity)}", isDark,
                        isNegative: true),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      child: Divider(
                          height: 1,
                          color: isDark
                              ? const Color(0xFF334155)
                              : const Color(0xFFE2E8F0)),
                    ),
                    _buildBreakdownRow("Net Disbursed Amount",
                        _formatAmount(payslip.netPay), isDark,
                        isBold: true),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  "Sharing PDF statement for ${payslip.month}...")),
                        );
                      },
                      icon: Icon(Icons.share_outlined, size: 16.sp),
                      label: const Text("Share"),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
                        side: BorderSide(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  "Downloading official PDF for ${payslip.id}")),
                        );
                      },
                      icon: Icon(Icons.file_download_outlined,
                          size: 16.sp, color: Colors.white),
                      label: const Text("Download PDF",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        backgroundColor: const Color(0xFF2563EB),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r)),
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

  Widget _buildBreakdownRow(String title, String amount, bool isDark,
      {bool isBold = false, bool isPositive = false, bool isNegative = false}) {
    Color amountColor = isDark ? Colors.white : const Color(0xFF0F172A);
    if (isPositive) amountColor = const Color(0xFF059669);
    if (isNegative) amountColor = const Color(0xFFE11D48);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isBold ? 13.sp : 11.5.sp,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
            color: isBold
                ? (isDark ? Colors.white : const Color(0xFF0F172A))
                : const Color(0xFF64748B),
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isBold ? 15.sp : 11.5.sp,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w700,
            color: amountColor,
          ),
        ),
      ],
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
  final double allowances;
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
    required this.allowances,
    required this.taxDeductions,
    required this.socialSecurity,
    required this.status,
    required this.year,
  });
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
        Text(label,
            style: TextStyle(fontSize: 9.5.sp, color: const Color(0xFF94A3B8))),
        SizedBox(height: 2.h),
        Text(value,
            style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
      ],
    );
  }
}

class _AnimatedPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _AnimatedPressable({required this.child, this.onTap});

  @override
  State<_AnimatedPressable> createState() => _AnimatedPressableState();
}

class _AnimatedPressableState extends State<_AnimatedPressable> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}
