import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CreateTravelRequestBottomSheet extends StatefulWidget {
  const CreateTravelRequestBottomSheet({super.key});

  @override
  State<CreateTravelRequestBottomSheet> createState() =>
      _CreateTravelRequestBottomSheetState();
}

class _CreateTravelRequestBottomSheetState
    extends State<CreateTravelRequestBottomSheet> {
  int _currentTabIndex = 0;

  final List<String> _tabs = [
    'Detail',
    'Dimension',
    'Driver',
    'Beneficiary Bank',
  ];

  // Form State
  String _selectedEmployee = '13331 | Borom Oum';
  String _selectedType = 'Local';
  String _selectedExpenseType = 'Not Required Advance';

  final TextEditingController _purposeController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // App Light Theme Color Palette
  static const Color _bgLight = Color(0xFFF8FAFC);
  static const Color _cardLight = Color(0xFFFFFFFF);
  static const Color _borderLight = Color(0xFFE2E8F0);
  static const Color _primaryLime = Color(0xFF8CBE23);
  static const Color _primaryAccent = Color(0xFF689F38);
  static const Color _textPrimary = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);

  @override
  void dispose() {
    _purposeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: _bgLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        border: Border.all(color: _borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 1. Sheet Drag Handle Bar
          SizedBox(height: 10.h),
          Container(
            width: 36.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // 2. Header
          Padding(
            padding: EdgeInsets.fromLTRB(20.w, 10.h, 12.w, 10.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.directions_car_rounded, color: _primaryAccent, size: 22.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Create Travel Request',
                      style: TextStyle(
                        color: _textPrimary,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.attach_file_rounded, color: _textMuted, size: 20.sp),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Attach Attachment/Receipt')),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: _textMuted, size: 22.sp),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 3. Tab Pill Selector Navigation
          SizedBox(
            height: 38.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: _tabs.length,
              itemBuilder: (context, index) {
                final isSelected = _currentTabIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => _currentTabIndex = index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: EdgeInsets.only(right: 8.w),
                    padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: isSelected ? _primaryLime : Colors.white,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: isSelected ? _primaryLime : _borderLight,
                        width: 1.2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _tabs[index],
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.black : _textMuted,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 14.h),

          // 4. Form Content Container
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              physics: const BouncingScrollPhysics(),
              child: Container(
                padding: EdgeInsets.all(18.r),
                decoration: BoxDecoration(
                  color: _cardLight,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: _borderLight),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IndexedStack(
                  index: _currentTabIndex,
                  children: [
                    _buildDetailTab(),
                    _buildDimensionTab(),
                    _buildDriverTab(),
                    _buildBeneficiaryBankTab(),
                  ],
                ),
              ),
            ),
          ),

          // 5. Sticky Bottom Action Buttons
          Container(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h + keyboardPadding),
            decoration: const BoxDecoration(
              color: _bgLight,
              border: Border(top: BorderSide(color: _borderLight)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Travel request submitted successfully!'),
                            backgroundColor: _primaryAccent,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryLime,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: SizedBox(
                    height: 48.h,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Request saved as draft')),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: _primaryAccent, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                      ),
                      child: Text(
                        'Save Draft',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: _primaryAccent,
                        ),
                      ),
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

  // TAB 1: Details
  Widget _buildDetailTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCustomDropdown(
          label: 'Employee',
          isRequired: true,
          value: _selectedEmployee,
          items: ['13331 | Borom Oum', '10042 | Sophea Chan', '10088 | Dara Sok'],
          onChanged: (val) => setState(() => _selectedEmployee = val!),
        ),
        SizedBox(height: 16.h),
        _buildCustomDropdown(
          label: 'Type',
          isRequired: true,
          value: _selectedType,
          items: ['Local', 'Branch Visit', 'Client Meeting', 'Field Audit'],
          onChanged: (val) => setState(() => _selectedType = val!),
        ),
        SizedBox(height: 16.h),
        _buildCustomDropdown(
          label: 'Trip Expense',
          isRequired: true,
          value: _selectedExpenseType,
          items: ['Not Required Advance', 'Required Advance', 'Company Direct Pay'],
          onChanged: (val) => setState(() => _selectedExpenseType = val!),
        ),
        SizedBox(height: 16.h),
        _buildCustomTextField(
          label: 'Purpose',
          isRequired: true,
          controller: _purposeController,
          hintText: 'Enter trip purpose or customer meeting detail...',
          maxLines: 3,
        ),
        SizedBox(height: 16.h),
        _buildCustomTextField(
          label: 'Additional Note',
          isRequired: false,
          controller: _noteController,
          hintText: 'Enter notes or specific requests...',
          maxLines: 3,
        ),
      ],
    );
  }

  // TAB 2: Cost Center
  Widget _buildDimensionTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCustomDropdown(
          label: 'Department / Cost Center',
          isRequired: true,
          value: 'Mobile App Engineering',
          items: ['Mobile App Engineering', 'Sales & Marketing', 'Operations & Logistics'],
          onChanged: (v) {},
        ),
        SizedBox(height: 16.h),
        _buildCustomDropdown(
          label: 'Project Code',
          isRequired: false,
          value: 'PRJ-2026-HQ',
          items: ['PRJ-2026-HQ', 'CLIENT-VISIT-01', 'BRANCH-EXPANSION'],
          onChanged: (v) {},
        ),
      ],
    );
  }

  // TAB 3: Driver & Vehicle
  Widget _buildDriverTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCustomDropdown(
          label: 'Vehicle Option',
          isRequired: true,
          value: 'Company Driver & Vehicle',
          items: ['Company Driver & Vehicle', 'Self-Drive Company Car', 'Personal Vehicle Claim', 'Grab / Taxi'],
          onChanged: (v) {},
        ),
        SizedBox(height: 16.h),
        _buildCustomTextField(
          label: 'Pickup Destination & Time',
          isRequired: false,
          controller: TextEditingController(text: 'Main HQ Office • 08:30 AM'),
          hintText: 'Enter pickup address',
          maxLines: 2,
        ),
      ],
    );
  }

  // TAB 4: Bank Details
  Widget _buildBeneficiaryBankTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCustomDropdown(
          label: 'Disbursement Bank',
          isRequired: true,
          value: 'ABA Bank - 000 123 456',
          items: ['ABA Bank - 000 123 456', 'Wing Bank - 012 998 776', 'Canadia Bank - 998 112 000'],
          onChanged: (v) {},
        ),
        SizedBox(height: 16.h),
        _buildCustomTextField(
          label: 'Account Holder Name',
          isRequired: true,
          controller: TextEditingController(text: 'BOROM OUM'),
          hintText: 'Account holder name',
        ),
      ],
    );
  }

  // Custom Outlined Dropdown Widget
  Widget _buildCustomDropdown({
    required String label,
    required bool isRequired,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return InputDecorator(
      decoration: InputDecoration(
        label: _buildFieldLabel(label, isRequired),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: _borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: _primaryAccent, width: 1.5),
        ),
        fillColor: Colors.white,
        filled: true,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          isExpanded: true,
          dropdownColor: Colors.white,
          icon: Icon(Icons.keyboard_arrow_down_rounded, color: _textMuted, size: 20.sp),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  color: _textPrimary,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // Custom Outlined Text Field
  Widget _buildCustomTextField({
    required String label,
    required bool isRequired,
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: _textPrimary, fontSize: 13.sp),
      decoration: InputDecoration(
        label: _buildFieldLabel(label, isRequired),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        hintText: hintText,
        hintStyle: TextStyle(color: const Color(0xFF94A3B8), fontSize: 12.sp),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: _borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: _primaryAccent, width: 1.5),
        ),
        fillColor: Colors.white,
        filled: true,
      ),
    );
  }

  Widget _buildFieldLabel(String label, bool isRequired) {
    return RichText(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: _textMuted,
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
        ),
        children: isRequired
            ? [
                TextSpan(
                  text: ' *',
                  style: TextStyle(color: Colors.redAccent, fontSize: 13.sp),
                ),
              ]
            : [],
      ),
    );
  }
}