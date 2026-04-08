import 'package:flutter/material.dart';
import '../models/models.dart';
import 'supervisor/projects_list.dart';
import 'supervisor/grades_entry.dart';
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

  // إحصائيات إضافية
  int _totalProjects = 0;
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
        _totalProjects = 12;
        _supervisorName = 'د. محمد أحمد الشامي';
        _departmentName = 'إدارة الأعمال';
        _programName = 'إدارة أعمال دولية';
      } else if (widget.supervisor != null) {
        final supervisorId = widget.supervisor!.id!;
        _groups = await SupabaseService.getGroupsBySupervisor(supervisorId);
        _totalProjects = _groups.length;

        final supervisorData = await SupabaseService.getSupervisorById(supervisorId);
        _supervisorName = supervisorData?.name ?? widget.supervisor?.name ?? 'المشرف';

        _programName = 'إدارة أعمال دولية'; // Default based on design
        _departmentName = 'إدارة الأعمال'; // Default based on design

        final programId = supervisorData?.programId;
        if (programId != null) {
          final program = await SupabaseService.getProgramById(programId);
          if (program != null) {
            _programName = program.name;
            final department = await SupabaseService.getDepartmentById(program.departmentId ?? 0);
            _departmentName = department?.name ?? 'إدارة الأعمال';
          }
        }
      }
    } catch (e) {
      debugPrint('خطأ في تحميل البيانات: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: Row(
              children: [
                _buildMainContent(),
                _buildSidebar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Row(
        children: [
          // Logout Icon
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red, size: 24),
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          ),
          const SizedBox(width: 16),
          // Notifications Icon
          Stack(
            children: [
              const Icon(Icons.notifications_none, color: Colors.grey, size: 28),
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          // User Info
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _supervisorName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const Text(
                'المشرف الأكاديمي',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFE0E0E0),
            child: Icon(Icons.person, color: Colors.white),
          ),
          const Spacer(),
          // System Name
          const Text(
            'نظام إدارة ومتابعة أبحاث التخرج',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF4A5568),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF2D62ED),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.school, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildSidebarItem(0, Icons.grid_view_rounded, 'لوحة التحكم'),
          _buildSidebarItem(1, Icons.people_outline, 'إدارة المجموعات'),
          _buildSidebarItem(2, Icons.chat_bubble_outline, 'الدردشات'),
          _buildSidebarItem(3, Icons.edit_note_rounded, 'إدخال الدرجات النهائية'),
          _buildSidebarItem(4, Icons.settings_outlined, 'الإعدادات'),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(int index, IconData icon, String title) {
    bool isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedIndex = index);
        if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SupervisorProjectsList(
                supervisorId: widget.supervisor?.id ?? 0,
                supervisorName: _supervisorName,
              ),
            ),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GradesEntry(
                supervisorId: widget.supervisor?.id ?? 0,
              ),
            ),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2D62ED) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2D62ED).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF718096),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 15,
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF718096),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text(
              'لوحة التحكم',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'مرحباً بك د. $_supervisorName',
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF718096),
              ),
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildInfoCard(
                  title: 'عدد الأبحاث التي أشرف عليها',
                  value: _totalProjects.toString(),
                  color: const Color(0xFF2D62ED),
                ),
                const SizedBox(width: 24),
                _buildInfoCard(
                  title: 'القسم',
                  value: _departmentName,
                  color: const Color(0xFF7C3AED),
                ),
                const SizedBox(width: 24),
                _buildInfoCard(
                  title: 'البرنامج',
                  value: _programName,
                  color: const Color(0xFF06B6D4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required String value, required Color color}) {
    return Container(
      width: 240,
      height: 160,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.right,
          ),
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
    );
  }
}
