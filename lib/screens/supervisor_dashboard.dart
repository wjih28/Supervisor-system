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
            supervisorId: 1,
            currentStage: 'final',
            createdAt: DateTime.now(),
          ),
          ResearchGroup(
            id: 2,
            name: 'دور الذكاء الاصطناعي في تطوير الأعمال',
            description: 'استكشاف تطبيقات الذكاء الاصطناعي في الشركات الناشئة',
            progress: 0.85,
            status: 'in_progress',
            supervisorId: 1,
            currentStage: 'final',
            createdAt: DateTime.now(),
          ),
          ResearchGroup(
            id: 3,
            name: 'إدارة الموارد البشرية في المؤسسات الحديثة',
            description: 'تحديات إدارة الموارد البشرية في العصر الرقمي',
            progress: 0.35,
            status: 'delayed',
            supervisorId: 1,
            currentStage: 'plan',
            createdAt: DateTime.now(),
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
        _pendingReviews = _groups.where((g) => g.currentStage != 'final').length; // Assuming 'final' means no pending reviews

        final supervisorData = await SupabaseService.getSupervisorById(supervisorId);
        _supervisorName = supervisorData?.name ?? widget.supervisor?.name ?? 'المشرف';

        _programName = 'غير محدد';
        _departmentName = 'غير محدد';

        final programId = supervisorData?.programId; // Assuming supervisor has a programId
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
          _buildSidebarItem(0, Icons.dashboard_outlined, 'لوحة التحكم'),
          const SizedBox(height: 8),
          _buildSidebarItem(1, Icons.groups_outlined, 'إدارة المجموعات'),
          const SizedBox(height: 8),
          _buildSidebarItem(2, Icons.chat_bubble_outline, 'الدردشات'),
          const SizedBox(height: 8),
          _buildSidebarItem(3, Icons.grade_outlined, 'إدخال الدرجات النهائية'),
          const SizedBox(height: 8),
          _buildSidebarItem(4, Icons.settings_outlined, 'الإعدادات'),
          const Spacer(),
          const Divider(),
          _buildSidebarItem(5, Icons.logout, 'تسجيل الخروج', isLogout: true),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String title, {bool isLogout = false}) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (isLogout) {
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          setState(() => _selectedIndex = index);
          _onNavigationItemSelected(index);
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

  void _onNavigationItemSelected(int index) {
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
            ),
          ),
          const SizedBox(width: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(
                  _supervisorName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.person_outline, color: Color(0xFF2D62ED)),
              ],
            ),
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
            'لوحة التحكم',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _buildDashboardCard(
                  title: 'إجمالي المشاريع',
                  value: _totalProjects.toString(),
                  icon: Icons.folder_open,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildDashboardCard(
                  title: 'مشاريع قيد العمل',
                  value: _inProgressProjects.toString(),
                  icon: Icons.timelapse,
                  color: Colors.orange,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildDashboardCard(
                  title: 'مشاريع مكتملة',
                  value: _completedProjects.toString(),
                  icon: Icons.check_circle_outline,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildDashboardCard(
                  title: 'مراجعات معلقة',
                  value: _pendingReviews.toString(),
                  icon: Icons.rate_review_outlined,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildSectionTitle('المشاريع الأخيرة'),
                    const SizedBox(height: 16),
                    _buildRecentProjectsList(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('معلومات المشرف'),
                    const SizedBox(height: 16),
                    _buildSupervisorInfoCard(),
                  ],
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                flex: 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildSectionTitle('ملخص الحالة'),
                    const SizedBox(height: 16),
                    _buildStatusSummaryCard(),
                    const SizedBox(height: 32),
                    _buildSectionTitle('الإشعارات'),
                    const SizedBox(height: 16),
                    _buildNotificationsCard(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(
      {required String title,
      required String value,
      required IconData icon,
      required Color color}) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Icon(icon, color: color, size: 36),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1A1A1A),
      ),
      textAlign: TextAlign.right,
    );
  }

  Widget _buildRecentProjectsList() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (_groups.isEmpty)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'لا توجد مشاريع حالياً.',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _groups.length > 3 ? 3 : _groups.length,
                itemBuilder: (context, index) {
                  final project = _groups[index];
                  return ListTile(
                    leading: const Icon(Icons.assignment, color: Color(0xFF2D62ED)),
                    title: Text(project.name, textAlign: TextAlign.right),
                    subtitle: Text(
                      'الحالة: ${_getStatusText(project.status)} - المرحلة: ${_getStageText(project.currentStage)}',
                      textAlign: TextAlign.right,
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProjectDetails(
                            projectId: project.id!,
                            supervisorId: widget.supervisor?.id ?? 0,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            if (_groups.length > 3)
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    _onNavigationItemSelected(1); // Navigate to Projects List
                  },
                  child: const Text('عرض كل المشاريع'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupervisorInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildInfoRow('الاسم:', _supervisorName, Icons.person),
            const Divider(),
            _buildInfoRow('القسم:', _departmentName, Icons.business),
            const Divider(),
            _buildInfoRow('البرنامج:', _programName, Icons.school),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Color(0xFF1A1A1A)),
            textAlign: TextAlign.right,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            textAlign: TextAlign.right,
          ),
          const SizedBox(width: 8),
          Icon(icon, color: const Color(0xFF2D62ED), size: 20),
        ],
      ),
    );
  }

  Widget _buildStatusSummaryCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildStatusItem('مكتملة', _completedProjects, Colors.green),
            const Divider(),
            _buildStatusItem('قيد العمل', _inProgressProjects, Colors.orange),
            const Divider(),
            _buildStatusItem('معلقة', _pendingProjects, Colors.blue),
            const Divider(),
            _buildStatusItem('متأخرة', _groups.where((g) => g.status == 'delayed').length, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            count.toString(),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 8),
          Icon(Icons.circle, color: color, size: 16),
        ],
      ),
    );
  }

  Widget _buildNotificationsCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Placeholder for notifications
            const Text(
              'لا توجد إشعارات جديدة.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            // Example notification item
            // ListTile(
            //   leading: Icon(Icons.notifications, color: Colors.blue),
            //   title: Text('تمت الموافقة على مقترح مشروع جديد'),
            //   subtitle: Text('قبل 5 دقائق'),
            // ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'in_progress':
        return 'قيد العمل';
      case 'completed':
        return 'مكتمل';
      case 'delayed':
        return 'متأخر';
      case 'pending_approval':
        return 'بانتظار الموافقة';
      default:
        return 'غير محدد';
    }
  }

  String _getStageText(String? stage) {
    switch (stage) {
      case 'proposal':
        return 'المقترح';
      case 'plan':
        return 'خطة البحث';
      case 'field':
        return 'الدراسة الميدانية';
      case 'final':
        return 'البحث النهائي';
      default:
        return stage ?? 'غير محدد';
    }
  }
}
