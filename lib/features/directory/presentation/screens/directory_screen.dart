import 'dart:ui';
import 'package:flutter/material.dart';

// ============================================================================
// DATA MODELS
// ============================================================================

class OrgNodeData {
  final String id;
  final String name;
  final String role;
  final String company;
  final String location;
  final String status;
  final String? avatar;
  final int childrenCount;
  bool isExpanded;
  final List<OrgNodeData> children;

  OrgNodeData({
    required this.id,
    required this.name,
    required this.role,
    required this.company,
    required this.location,
    required this.status,
    this.avatar,
    required this.childrenCount,
    this.isExpanded = false,
    this.children = const [],
  });
}

class CompanyData {
  final String id;
  final String name;
  final String desc;
  final String employees;
  final String icon;

  CompanyData(this.id, this.name, this.desc, this.employees, this.icon);
}

class DepartmentData {
  final String id;
  final String name;
  final int employees;
  final String icon;

  DepartmentData(this.id, this.name, this.employees, this.icon);
}

// Updated Dummy Data with custom profile image URLs
final OrgNodeData orgData = OrgNodeData(
  id: "1",
  name: "David Smith",
  role: "Chief Executive Officer",
  company: "ISI Group",
  location: "Phnom Penh",
  status: "online",
  avatar: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSZ7qnrDd-bAPN3GW3BP0rW3d_9067C6BFQmWWeWuegcg&s=10",
  childrenCount: 4,
  isExpanded: true,
  children: [
    OrgNodeData(
      id: "2",
      name: "Sarah Jenkins",
      role: "Chief Operating Officer",
      company: "ISI Group",
      location: "Phnom Penh",
      status: "online",
      avatar: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQXJwlpWlgmH8Y2F8bEK1uZUiFoU1ljVJCl8Ag_jJydag&s=10",
      childrenCount: 12,
      isExpanded: true,
      children: [
        OrgNodeData(
          id: "4",
          name: "Michael Chen",
          role: "IT Director",
          company: "ISI Tech",
          location: "Phnom Penh",
          status: "online",
          avatar: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSzLyIps5QjGCYNaevc8w8hYOJOIWbaBzhEN-wLhtlNOA&s=10",
          childrenCount: 8,
          isExpanded: false,
        ),
        OrgNodeData(
          id: "5",
          name: "Emma Watson",
          role: "HR Director",
          company: "ISI Group",
          location: "Phnom Penh",
          status: "offline",
          avatar: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQtjd83GA9q2b3s7GVLvlYwx1QQGcQAMb-ZbvEUaAS3tw&s=10",
          childrenCount: 5,
          isExpanded: false,
        ),
      ],
    ),
    OrgNodeData(
      id: "3",
      name: "James Wilson",
      role: "Chief Financial Officer",
      company: "ISI Group",
      location: "Phnom Penh",
      status: "away",
      avatar: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQlK2S9E-TMviFgtQl8XYf0DktCxjmmuWYv9T_K6vkmQg&s=10",
      childrenCount: 6,
      isExpanded: false,
    ),
    OrgNodeData(
      id: "6",
      name: "Alex Rivera",
      role: "Marketing Director",
      company: "ISI Group",
      location: "Phnom Penh",
      status: "online",
      avatar: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ0RrCC4vskzKivKbKMIJmrqw3UggZ9do60-W7kOC-6ag&s=10",
      childrenCount: 3,
      isExpanded: false,
    ),
    OrgNodeData(
      id: "7",
      name: "Linda Thorne",
      role: "Head of Operations",
      company: "ISI Logistics",
      location: "Phnom Penh",
      status: "online",
      avatar: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRkbrbZXaYYcWXzMGnt-GvRp6nUqQ5KEVnpADgRRRR7bw&s=10",
      childrenCount: 2,
      isExpanded: false,
    ),
  ],
);

final List<CompanyData> companiesList = [
  CompanyData("c1", "ISI Steel", "Manufacturing & Distribution", "2,350", "🏢"),
  CompanyData("c2", "ISI E&C", "Engineering & Construction", "850", "🏗"),
  CompanyData("c3", "ISI Logistics", "Transportation", "420", "🚚"),
  CompanyData("c4", "Corporate Office", "Shared Services", "560", "🏢"),
];

final List<DepartmentData> departmentsList = [
  DepartmentData("d1", "IT Innovation", 145, "💻"),
  DepartmentData("d2", "Finance", 63, "💰"),
  DepartmentData("d3", "Human Resources", 41, "👥"),
  DepartmentData("d4", "Marketing", 55, "📢"),
  DepartmentData("d5", "Warehouse", 320, "📦"),
  DepartmentData("d6", "Factory", 890, "🏭"),
];

// ============================================================================
// MAIN DIRECTORY SCREEN
// ============================================================================

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> {
  final TransformationController _transformationController = TransformationController();
  
  @override
  void initState() {
    super.initState();
    _transformationController.value = Matrix4.identity()..scale(0.8);
  }

  void _zoomIn() {
    final matrix = _transformationController.value;
    matrix.scale(1.1);
    _transformationController.value = matrix;
  }

  void _zoomOut() {
    final matrix = _transformationController.value;
    matrix.scale(0.9);
    _transformationController.value = matrix;
  }

  void _resetZoom() {
    _transformationController.value = Matrix4.identity()
      ..translate(0.0, 50.0)
      ..scale(0.8);
  }

  void _openFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        onApply: (filters) {
          debugPrint("Filters applied: $filters");
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FA),
      body: Stack(
        children: [
          // 1. Grid Background Pattern
          const Positioned.fill(
            child: CleanGridBackground(),
          ),

          // 2. Interactive Tree Viewer
          Positioned.fill(
            child: InteractiveViewer(
              transformationController: _transformationController,
              constrained: false,
              boundaryMargin: const EdgeInsets.all(double.infinity),
              minScale: 0.1,
              maxScale: 2.0,
              child: Padding(
                padding: const EdgeInsets.only(top: 150.0),
                child: OrgNodeWidget(node: orgData),
              ),
            ),
          ),

          // 3. Search Bar Header
          Positioned(
            top: 48,
            left: 16,
            right: 16,
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 8),
                            const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F172A),
                                ),
                                decoration: const InputDecoration(
                                  hintText: "Search employees, departments...",
                                  hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _openFilter,
                  child: Container(
                    height: 52,
                    width: 52,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: const Icon(Icons.tune_rounded, color: Color(0xFF475569), size: 20),
                  ),
                ),
              ],
            ),
          ),

          // 4. Floating Action Zoom Controls
          Positioned(
            bottom: 32,
            right: 16,
            child: Column(
              children: [
                _buildFloatingBtn(Icons.zoom_in, _zoomIn),
                const SizedBox(height: 8),
                _buildFloatingBtn(Icons.zoom_out, _zoomOut),
                const SizedBox(height: 16),
                _buildFloatingBtn(Icons.crop_free, _resetZoom),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFloatingBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Icon(icon, color: const Color(0xFF475569), size: 20),
      ),
    );
  }
}

// ============================================================================
// ORGANIZATION NODE WIDGET (RECURSIVE)
// ============================================================================

class OrgNodeWidget extends StatefulWidget {
  final OrgNodeData node;
  final int level;

  const OrgNodeWidget({super.key, required this.node, this.level = 0});

  @override
  State<OrgNodeWidget> createState() => _OrgNodeWidgetState();
}

class _OrgNodeWidgetState extends State<OrgNodeWidget> {
  late bool expanded;
  bool isHovered = false;

  @override
  void initState() {
    super.initState();
    expanded = widget.node.isExpanded;
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'online': return const Color(0xFF10B981);
      case 'away': return const Color(0xFFFBBF24);
      default: return const Color(0xFFCBD5E1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: 240,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0).withValues(alpha: 0.6)),
                  boxShadow: [
                    BoxShadow(
                      color: isHovered 
                          ? const Color(0xFF2563EB).withValues(alpha: 0.08)
                          : const Color(0xFF0F172A).withValues(alpha: 0.06),
                      blurRadius: isHovered ? 32 : 24,
                      offset: Offset(0, isHovered ? 12 : 8),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 56,
                          width: 56,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF0F172A).withValues(alpha: 0.05)),
                          ),
                          clipBehavior: Clip.hardEdge,
                          child: widget.node.avatar != null
                              ? Image.network(
                                  widget.node.avatar!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Center(
                                    child: Text(
                                      widget.node.name[0],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    widget.node.name[0],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                    
                    Text(
                      widget.node.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), height: 1.2),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.node.role,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2563EB)),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on_outlined, size: 12, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Text(widget.node.location, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
                        const SizedBox(width: 8),
                        Container(width: 4, height: 4, decoration: const BoxDecoration(color: Color(0xFFCBD5E1), shape: BoxShape.circle)),
                        const SizedBox(width: 8),
                        Text(widget.node.company, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
                      ],
                    ),

                    AnimatedOpacity(
                      opacity: isHovered ? 1.0 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          border: Border(top: BorderSide(color: Color(0xFFF1F5F9))),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildActionBtn(Icons.mail_outline, const Color(0xFFEFF6FF), const Color(0xFF2563EB)),
                            const SizedBox(width: 4),
                            _buildActionBtn(Icons.phone_outlined, const Color(0xFFECFDF5), const Color(0xFF10B981)),
                            const SizedBox(width: 4),
                            _buildActionBtn(Icons.more_vert, const Color(0xFFF1F5F9), const Color(0xFF475569)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  height: 10,
                  width: 10,
                  decoration: BoxDecoration(
                    color: getStatusColor(widget.node.status),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
              ),

              // Enhanced Dropdown Toggle Button with enlarged hit target & smooth rotation animation
              if (widget.node.childrenCount > 0)
                Positioned(
                  bottom: -20,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        expanded = !expanded;
                        widget.node.isExpanded = expanded;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            )
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.people_outline, size: 12, color: Color(0xFF475569)),
                            const SizedBox(width: 4),
                            Text(
                              "${widget.node.childrenCount}",
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF475569)),
                            ),
                            const SizedBox(width: 3),
                            AnimatedRotation(
                              turns: expanded ? 0.5 : 0.0,
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                              child: const Icon(
                                Icons.expand_more,
                                size: 14,
                                color: Color(0xFF475569),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        if (expanded && widget.node.children.isNotEmpty)
          Column(
            children: [
              Container(width: 1, height: 24, color: const Color(0xFFCBD5E1), margin: const EdgeInsets.only(top: 12)),
              
              Stack(
                children: [
                  if (widget.node.children.length > 1)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          double halfWidth = (constraints.maxWidth / widget.node.children.length) / 2;
                          return Container(
                            margin: EdgeInsets.only(left: halfWidth, right: halfWidth),
                            height: 1,
                            color: const Color(0xFFCBD5E1),
                          );
                        },
                      ),
                    ),
                    
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.node.children.map((child) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            Container(width: 1, height: 24, color: const Color(0xFFCBD5E1)),
                            OrgNodeWidget(node: child, level: widget.level + 1),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildActionBtn(IconData icon, Color hoverBg, Color iconColor) {
    return Container(
      height: 32,
      width: 32,
      decoration: const BoxDecoration(color: Color(0xFFF8FAFC), shape: BoxShape.circle),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          hoverColor: hoverBg,
          onTap: () {},
          child: Icon(icon, size: 16, color: iconColor),
        ),
      ),
    );
  }
}

// ============================================================================
// FILTER BOTTOM SHEET
// ============================================================================

class FilterBottomSheet extends StatefulWidget {
  final Function(Map<String, dynamic>) onApply;

  const FilterBottomSheet({super.key, required this.onApply});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? selectedCompany;
  List<String> selectedDeps = [];

  void toggleDep(String id) {
    setState(() {
      if (selectedDeps.contains(id)) {
        selectedDeps.remove(id);
      } else {
        selectedDeps.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.9;

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 40, offset: Offset(0, -10))
        ],
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  height: 6,
                  width: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text("Filter Organization", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), letterSpacing: -0.5)),
                          SizedBox(height: 4),
                          Text("Quickly explore employees by company, department, and more.", style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() { selectedCompany = null; selectedDeps.clear(); }),
                      child: const Text("Reset All", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF2563EB))),
                    )
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 120),
                  children: [
                    if (selectedCompany != null || selectedDeps.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            if (selectedCompany != null)
                              _buildFilterChip(
                                companiesList.firstWhere((c) => c.id == selectedCompany).name,
                                const Color(0xFFEFF6FF), const Color(0xFF1D4ED8), const Color(0xFFDBEAFE),
                                () => setState(() => selectedCompany = null),
                              ),
                            ...selectedDeps.map((id) => _buildFilterChip(
                                  departmentsList.firstWhere((d) => d.id == id).name,
                                  Colors.white, const Color(0xFF334155), const Color(0xFFE2E8F0),
                                  () => toggleDep(id),
                                )),
                          ],
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9).withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0).withValues(alpha: 0.5)),
                          ),
                          child: const Center(
                            child: Text("No filters applied. Showing entire organization.", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
                          ),
                        ),
                      ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Company", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                          const SizedBox(height: 16),
                          _buildSearchBar("Search companies..."),
                          const SizedBox(height: 12),
                          ...companiesList.map((company) => _buildCompanyItem(company)),
                        ],
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Divider(color: Color(0xFFE2E8F0)),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Department", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                              if (selectedDeps.isNotEmpty)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(6)),
                                  child: Text("${selectedDeps.length} Selected", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                                )
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildSearchBar("Search departments..."),
                          const SizedBox(height: 12),
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.5,
                            children: departmentsList.map((dep) => _buildDepartmentItem(dep)).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: MediaQuery.of(context).padding.bottom + 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    border: Border(top: BorderSide(color: const Color(0xFFE2E8F0).withValues(alpha: 0.6))),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text("RESULTS PREVIEW", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B), letterSpacing: 0.5)),
                          Text("1,243 Employees", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () {
                          widget.onApply({'company': selectedCompany, 'departments': selectedDeps});
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: 56,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(color: const Color(0xFF0F172A).withValues(alpha: 0.15), blurRadius: 20, offset: const Offset(0, 8))
                            ]
                          ),
                          child: const Center(
                            child: Text("Apply Filters", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, Color bg, Color textC, Color borderC, VoidCallback onRemove) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderC),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: textC)),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRemove,
            child: Icon(Icons.close, size: 14, color: textC.withValues(alpha: 0.7)),
          )
        ],
      ),
    );
  }

  Widget _buildSearchBar(String hint) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0).withValues(alpha: 0.6)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          const Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCompanyItem(CompanyData company) {
    final isSelected = selectedCompany == company.id;
    return GestureDetector(
      onTap: () => setState(() => selectedCompany = company.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF).withValues(alpha: 0.5) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFFBFDBFE) : const Color(0xFFE2E8F0).withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            Text(company.icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(company.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                  Text(company.desc, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF64748B))),
                  const SizedBox(height: 4),
                  Text("${company.employees} Employees", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF94A3B8))),
                ],
              ),
            ),
            Container(
              height: 24, width: 24,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0), width: 2),
              ),
              child: isSelected ? const Icon(Icons.check, size: 14, color: Colors.white) : null,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildDepartmentItem(DepartmentData dep) {
    final isSelected = selectedDeps.contains(dep.id);
    return GestureDetector(
      onTap: () => toggleDep(dep.id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F172A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0).withValues(alpha: 0.6)),
          boxShadow: isSelected ? [const BoxShadow(color: Colors.black12, blurRadius: 16, offset: Offset(0, 8))] : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(dep.icon, style: const TextStyle(fontSize: 20)),
                Container(
                  height: 16, width: 16,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFFCBD5E1)),
                  ),
                  child: isSelected ? const Icon(Icons.check, size: 12, color: Colors.white) : null,
                )
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(dep.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : const Color(0xFF0F172A))),
                const SizedBox(height: 4),
                Text("${dep.employees} Employees", style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isSelected ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
              ],
            )
          ],
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
    canvas.drawColor(const Color(0xFFF4F7FA), BlendMode.srcOver);

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