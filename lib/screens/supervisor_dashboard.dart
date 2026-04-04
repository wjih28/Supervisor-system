import 'package:flutter/material.dart';
import 'package:graduation_research_management/models/models.dart';
import 'package:graduation_research_management/screens/supervisor/projects_list.dart';
import 'package:graduation_research_management/screens/supervisor/grades_entry.dart';
import 'package:graduation_research_management/services/supabase_service.dart';

class SupervisorDashboard extends StatefulWidget {
  final Supervisor? supervisor;
  final bool isGuest;

  const SupervisorDashboard({super.key, this.supervisor, this.isGuest = false});

  @override
  State<SupervisorDashboard> createState() => _SupervisorDashboardState();
}

class _SupervisorDashboardState extends State<SupervisorDashboard> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  List<ResearchGroup> _groups = [];

  // إحصائيات إضافية
  int _totalProjects = 0;
  int _completedProjects = 0;
  int _inProgressProjects = 0;
  int _pendingProjects = 0;
  int _pendingReviews = 0;
  String _supervisorName = '';
  String _departmentName = '';
  String _programName = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      if (widget.isGuest) {
        _groups = [
          ResearchGroup(
            id: 1,
            name: 'تأثير التسويق الرقمي على سلوك المستهلك',
            description: 'دراسة تحليلية لسلوك المستهلك في ظل التحول الرقمي',
            progress: 0.68,
            status: 'in_progress',
          ),
          ResearchGroup(
            id: 2,
            name: 'دور الذكاء الاصطناعي في تطوير الأعمال',
            description: 'استكشاف تطبيقات الذكاء الاصطناعي في الشركات الناشئة',
            progress: 0.85,
            status: 'in_progress',
          ),
          ResearchGroup(
            id: 3,
            name: 'إدارة الموارد البشرية في المؤسسات الحديثة',
            description: 'تحديات إدارة الموارد البشرية في العصر الرقمي',
            progress: 0.35,
            status: 'delayed',
          ),
        ];

        _totalProjects = 3;
        _inProgressProjects = 2;
        _completedProjects = 0;
        _pendingProjects = 1;
        _pendingReviews = 1;
        _supervisorName = 'د. محمد أحمد الشامي';
        _departmentName = 'إدارة الأعمال';
        _programName = 'إدارة أعمال دولية';
      } else if (widget.supervisor != null) {
        final supervisorId = widget.supervisor!.id!;
        _groups = await SupabaseService.getGroupsBySupervisor(supervisorId);

        _totalProjects = _groups.length;
        _inProgressProjects = _groups.where((g) => g.status == 'in_progress').length;
        _completedProjects = _groups.where((g) => g.status == 'completed').length;
        _pendingProjects = _groups.where((g) => g.status == 'pending_approval').length;
        _pendingReviews = _groups.where((g) => g.stateId != 3).length;

        final supervisorData = await SupabaseService.getSupervisorById(supervisorId);
        _supervisorName = supervisorData?.name ?? widget.supervisor?.name ?? 'المشرف';

        _programName = 'غير محدد';
        _departmentName = 'غير محدد';

        final programId = _groups.isNotEmpty ? _groups.first.stateId : null;
        if (programId != null) {
          final program = await SupabaseService.getProgramById(programId);
          if (program != null) {
            _programName = program.name;
            final department = await SupabaseService.getDepartmentById(program.departmentId ?? 0);
            _departmentName = department?.name ?? 'غير محدد';
          }
        }
      } else {
        _groups = [];
        _totalProjects = 0;
        _inProgressProjects = 0;
        _completedProjects = 0;
        _pendingProjects = 0;
        _pendingReviews = 0;
        _supervisorName = 'المشرف';
        _departmentName = 'غير محدد';
        _programName = 'غير محدد';
      }
    } catch (e) {
      debugPrint('خطأ في تحميل البيانات: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _buildMainContent(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 280,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 30),
          // Logo and System Name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'نظام إدارة ومتابعة أبحاث التخرج',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A1A),
                        ),
                        textAlign: TextAlign.right,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Graduation Research Management',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D62ED),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child:
                      const Icon(Icons.school, color: Colors.white, size: 24),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          // Navigation Items
          buildSidebarItem(0, Icons.dashboard_outlined, 'لوحة التحكم'),
          const SizedBox(height: 8),
          buildSidebarItem(1, Icons.groups_outlined, 'إدارة المجموعات'),
          const SizedBox(height: 8),
          buildSidebarItem(2, Icons.chat_bubble_outline, 'الدردشات'),
          const SizedBox(height: 8),
          buildSidebarItem(3, Icons.grade_outlined, 'إدخال الدرجات النهائية'),
          const SizedBox(height: 8),
          buildSidebarItem(4, Icons.settings_outlined, 'الإعدادات'),
          const Spacer(),
          const Divider(),
          buildSidebarItem(5, Icons.logout, 'تسجيل الخروج', isLogout: true),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget buildSidebarItem(int index, IconData icon, String title, {bool isLogout = false}) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (isLogout) {
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          setState(() => _selectedIndex = index);
          onNavigationItemSelected(index);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2D62ED) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey.shade600,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  void onNavigationItemSelected(int index) {
    switch (index) {
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SupervisorProjectsList(
              supervisorId: widget.supervisor?.id ?? 0,
              supervisorName: _supervisorName,
            ),
          ),
        );
        break;
      case 2:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('قريباً: نظام الدردشات')),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GradesEntry(
              supervisorId: widget.supervisor?.id ?? 0,
            ),
          ),
        );
        break;
      case 4:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('قريباً: الإعدادات')),
        );
        break;
      default:
        break;
    }
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      color: Colors.white,
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'نظام إدارة ومتابعة أبحاث التخرج',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
              textAlign: TextAlign.right,
            ),
          ),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.notifications_outlined, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _supervisorName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'مشرف أكاديمي',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              const CircleAvatar(
                backgroundColor: Color(0xFF2D62ED),
                child: Icon(Icons.person, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text(
            'نظرة عامة',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              buildInfoCard('إجمالي المجموعات', _totalProjects.toString(), const Color(0xFF2D62ED)),
              const SizedBox(width: 20),
              buildInfoCard('مجموعات قيد العمل', _inProgressProjects.toString(), const Color(0xFFF9A825)),
              const SizedBox(width: 20),
              buildInfoCard('مجموعات مكتملة', _completedProjects.toString(), const Color(0xFF4CAF50)),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              buildSmallStatCard('طلبات معلقة', _pendingProjects.toString(), Colors.orange, Icons.pending_actions),
              const SizedBox(width: 20),
              buildSmallStatCard('مراجعات مطلوبة', _pendingReviews.toString(), Colors.blue, Icons.rate_review_outlined),
            ],
          ),
          const SizedBox(height: 40),
          const Text(
            'المجموعات البحثية الحالية',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 20),
          _groups.isEmpty
              ? const Center(child: Text('لا توجد مجموعات حالياً'))
              : GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1.5,
                  ),
                  itemCount: _groups.length,
                  itemBuilder: (context, index) => buildGroupCard(_groups[index]),
                ),
        ],
      ),
    );
  }

  Widget buildInfoCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSmallStatCard(String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade50,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGroupCard(ResearchGroup group) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/supervisor/project_details',
          arguments: group.id,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (group.status == 'delayed')
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                Expanded(
                  child: Text(
                    group.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'قائد الفريق: ${group.leaderId != null ? 'ID ${group.leaderId}' : 'غير محدد'}',
              style: const TextStyle(
                color: Color(0xFF2D62ED),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${((group.progress ?? 0) * 100).toInt()}%',
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const Text(
                  'نسبة الإنجاز',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: group.progress ?? 0,
                backgroundColor: Colors.grey.shade100,
                valueColor: AlwaysStoppedAnimation<Color>(
                  group.status == 'delayed'
                      ? Colors.red
                      : group.status == 'completed'
                          ? Colors.green
                          : const Color(0xFF2D62ED),
                ),
                minHeight: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
