import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';

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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
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
    } else if (widget.supervisor != null) {
      _groups = await SupabaseService.getGroupsBySupervisor(widget.supervisor!.id!);
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: Row(
        children: [
          // Sidebar
          _buildSidebar(),
          // Main Content
          Expanded(
            child: Column(
              children: [
                _buildHeader(),
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
      width: 260,
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 40),
          // Logo
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D62ED),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.school, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              const Text(
                'نظام إدارة الأبحاث',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          _buildSidebarItem(0, Icons.dashboard_outlined, 'لوحة التحكم'),
          _buildSidebarItem(1, Icons.groups_outlined, 'إدارة المجموعات'),
          _buildSidebarItem(2, Icons.chat_bubble_outline, 'الدردشات'),
          _buildSidebarItem(3, Icons.grade_outlined, 'إدخال الدرجات النهائية'),
          _buildSidebarItem(4, Icons.settings_outlined, 'الإعدادات'),
          const Spacer(),
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
          Navigator.pop(context);
        } else {
          setState(() => _selectedIndex = index);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2D62ED) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey,
              size: 22,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    String name = widget.isGuest ? 'د. محمد أحمد الشامي' : (widget.supervisor?.name ?? 'المشرف');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      color: Colors.white,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مرحباً بك، $name',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
              const Text(
                'المشرف الأكاديمي',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.grey),
            onPressed: () {},
          ),
          const SizedBox(width: 16),
          CircleAvatar(
            backgroundColor: Colors.grey.shade200,
            child: const Icon(Icons.person, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Cards
          Row(
            children: [
              _buildStatCard('عدد الأبحاث التي أشرف عليها', _groups.length.toString(), const Color(0xFF2D62ED)),
              const SizedBox(width: 20),
              _buildStatCard('القسم', 'إدارة الأعمال', const Color(0xFF6C63FF)),
              const SizedBox(width: 20),
              _buildStatCard('البرنامج', 'إدارة أعمال دولية', const Color(0xFF00C9A7)),
            ],
          ),
          const SizedBox(height: 40),
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

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupCard(ResearchGroup group) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  group.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A1A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (group.status == 'delayed')
                const Icon(Icons.error_outline, color: Colors.red, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'قائد الفريق: أحمد محمد علي', // مثال
            style: TextStyle(color: Color(0xFF2D62ED), fontSize: 12),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'نسبة الإنجاز',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                '${((group.progress ?? 0) * 100).toInt()}%',
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontWeight: FontWeight.bold,
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
                group.status == 'delayed' ? Colors.red : const Color(0xFF2D62ED),
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
