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

  String _supervisorName = '';
  String _departmentName = '';
  String _programName = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

<<<<<<< Updated upstream
  Future<void> _loadDashboardData() async {
    if (widget.supervisor == null) {
      setState(() => _isLoading = false);
      return;
    }

=======
  Future<void> _loadData() async {
>>>>>>> Stashed changes
    setState(() => _isLoading = true);

    try {
<<<<<<< Updated upstream
      // جلب المجموعات الحقيقية من قاعدة البيانات
      final groups = await SupabaseService.getGroupsBySupervisor(widget.supervisor!.id!);
      
      setState(() {
        _groups = groups;
        _totalGroups = groups.length;
        // حالياً سنفترض أن المجموعات التي حالتها ليست "مكتملة" تحتاج مراجعة
        _pendingReviews = groups.where((g) => g.stateId != 3).length; 
        _isLoading = false;
      });
=======
      if (widget.isGuest) {
        // بيانات وهمية للتجربة
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
        _supervisorName = 'د. محمد أحمد الشامي';
        _departmentName = 'إدارة الأعمال';
        _programName = 'إدارة أعمال دولية';
      } else if (widget.supervisor != null) {
        // جلب المشاريع من قاعدة البيانات
        final supervisorId = widget.supervisor!.id!;
        _groups = await SupabaseService.getGroupsBySupervisor(supervisorId);

        // حساب الإحصائيات
        _totalProjects = _groups.length;
        _inProgressProjects =
            _groups.where((g) => g.status == 'in_progress').length;
        _completedProjects =
            _groups.where((g) => g.status == 'completed').length;
        _pendingProjects =
            _groups.where((g) => g.status == 'pending_approval').length;

        // جلب معلومات المشرف من Supabase
        final supervisorData =
            await SupabaseService.getSupervisorById(supervisorId);
        _supervisorName =
            supervisorData?.name ?? widget.supervisor?.name ?? 'المشرف';

        // جلب معلومات القسم والبرنامج من أول مشروع (إذا وجد)
        _programName = 'غير محدد';
        _departmentName = 'غير محدد';

        if (_groups.isNotEmpty && _groups.first.stateId != null) {
          final program =
              await SupabaseService.getProgramById(_groups.first.stateId!);
          if (program != null) {
            _programName = program.name;
            final department = await SupabaseService.getDepartmentById(
                program.departmentId ?? 0);
            _departmentName = department?.name ?? 'غير محدد';
          }
        }
      }
>>>>>>> Stashed changes
    } catch (e) {
      debugPrint('خطأ في تحميل البيانات: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  int _totalGroups = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< Updated upstream
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _buildAppBar(),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _loadDashboardData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeHeader(),
                  const SizedBox(height: 25),
                  _buildStatsGrid(),
                  const SizedBox(height: 30),
                  _buildSectionHeader('المجموعات التي تشرف عليها', Icons.group_work_rounded),
                  const SizedBox(height: 15),
                  _groups.isEmpty 
                    ? _buildEmptyState()
                    : _buildProjectsList(),
                ],
              ),
            ),
          ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // إضافة مهمة جديدة للطلاب
        },
        backgroundColor: const Color(0xFF2D62ED),
        icon: const Icon(Icons.add_task, color: Colors.white),
        label: const Text('إضافة مهمة', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      title: const Text(
        'لوحة تحكم المشرف',
        style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold, fontSize: 20),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.red),
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(width: 10),
      ],
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مرحباً، ${widget.supervisor?.name ?? "المشرف"} 👋',
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 6),
        Text(
          _pendingReviews > 0 
            ? 'لديك $_pendingReviews مجموعات تحتاج مراجعتك.'
            : 'كل المجموعات محدثة حالياً.',
          style: const TextStyle(color: Color(0xFF64748B), fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        _buildStatCard('إجمالي المجموعات', _totalGroups.toString(), Icons.groups_rounded, Colors.blue),
        const SizedBox(width: 15),
        _buildStatCard('تحتاج مراجعة', _pendingReviews.toString(), Icons.pending_actions_rounded, Colors.orange),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, 10)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 15),
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1E293B), size: 22),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(Icons.group_off_outlined, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('لا توجد مجموعات مرتبطة بك حالياً', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectsList() {
    return Column(
      children: _groups.map((group) => _buildProjectCard(
        group.name,
        'المجموعة ${group.id}',
        0.5, // قيمة افتراضية للتقدم حالياً
        group.stateId == 3 ? 'مكتمل' : 'قيد العمل',
        group.stateId == 3 ? Colors.green : Colors.blue,
      )).toList(),
    );
  }

  Widget _buildProjectCard(String title, String groupName, double progress, String status, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
=======
      backgroundColor: const Color(0xFFF8F9FD),
      body: Row(
>>>>>>> Stashed changes
        children: [
          // Sidebar (Right side - RTL)
          _buildSidebar(),
          // Main Content
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

  Widget _buildSidebarItem(int index, IconData icon, String title,
      {bool isLogout = false}) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        if (isLogout) {
          // تسجيل الخروج
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
        // إدارة المجموعات - عرض قائمة المشاريع
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
        // الدردشات (سيتم إضافتها لاحقاً)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('قريباً: نظام الدردشات')),
        );
        break;
      case 3:
        // إدخال الدرجات
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
        // الإعدادات (سيتم إضافتها لاحقاً)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('قريباً: الإعدادات')),
        );
        break;
    }
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      color: Colors.white,
      child: Row(
        children: [
          // Right side - System name
          const Expanded(
            child: Text(
              'نظام إدارة ومتابعة أبحاث التخرج',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // Left side - User info and notifications
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none,
                    color: Colors.grey, size: 24),
                onPressed: () {
                  Navigator.pushNamed(context, '/supervisor/notifications');
                },
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _supervisorName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                  const Text(
                    'المشرف الأكاديمي',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D62ED),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 20),
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
          // Welcome Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D62ED),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.dashboard, color: Colors.white, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'لوحة التحكم',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'لوحة التحكم',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A1A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'مرحباً بك $_supervisorName',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Stats Cards
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildInfoCard(
                'عدد الأبحاث التي أشرف عليها',
                _totalProjects.toString(),
                const Color(0xFF2D62ED),
              ),
              const SizedBox(width: 20),
              _buildInfoCard(
                'القسم',
                _departmentName,
                const Color(0xFF6C63FF),
              ),
              const SizedBox(width: 20),
              _buildInfoCard(
                'البرنامج',
                _programName,
                const Color(0xFF00C9A7),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Additional Stats - Progress Overview
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildSmallStatCard(
                'قيد التنفيذ',
                _inProgressProjects.toString(),
                Colors.orange,
                Icons.play_circle_outline,
              ),
              const SizedBox(width: 20),
              _buildSmallStatCard(
                'قيد المراجعة',
                _pendingProjects.toString(),
                Colors.purple,
                Icons.pending_actions_outlined,
              ),
              const SizedBox(width: 20),
              _buildSmallStatCard(
                'مكتملة',
                _completedProjects.toString(),
                Colors.green,
                Icons.check_circle_outline,
              ),
            ],
          ),
          const SizedBox(height: 40),
          // Research Progress Section
          const Text(
            'نسبة إنجاز الأبحاث',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 20),
          // Groups Grid
          if (_groups.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.folder_open,
                        size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'لا توجد مشاريع حالياً',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 1.8,
              ),
              itemCount: _groups.length,
              itemBuilder: (context, index) {
                return _buildGroupCard(_groups[index]);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, Color color) {
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

  Widget _buildSmallStatCard(
      String title, String value, Color color, IconData icon) {
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

  Widget _buildGroupCard(ResearchGroup group) {
    return GestureDetector(
      onTap: () {
        // الانتقال إلى صفحة تفاصيل المشروع
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
