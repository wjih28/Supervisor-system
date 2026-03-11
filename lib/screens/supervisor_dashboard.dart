import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupervisorDashboard extends StatefulWidget {
  const SupervisorDashboard({super.key});

  @override
  State<SupervisorDashboard> createState() => _SupervisorDashboardState();
}

class _SupervisorDashboardState extends State<SupervisorDashboard> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  String _supervisorName = "د. أحمد";
  int _totalGroups = 0;
  int _pendingReviews = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      // هنا سيتم جلب البيانات الحقيقية من Supabase لاحقاً
      // حالياً سنحاكي جلب البيانات
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _totalGroups = 8;
        _pendingReviews = 3;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading dashboard: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  _buildProjectsList(),
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
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Color(0xFF64748B), size: 28),
              onPressed: () {},
            ),
            Positioned(
              right: 12,
              top: 12,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        const CircleAvatar(
          radius: 18,
          backgroundColor: Color(0xFFE2E8F0),
          child: Icon(Icons.person, color: Color(0xFF64748B)),
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مرحباً، $_supervisorName 👋',
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 6),
        Text(
          'لديك $_pendingReviews مجموعات تنتظر مراجعتك اليوم.',
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
        _buildStatCard('قيد المراجعة', _pendingReviews.toString(), Icons.pending_actions_rounded, Colors.orange),
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

  Widget _buildProjectsList() {
    return Column(
      children: [
        _buildProjectCard(
          'نظام إدارة المستشفيات الذكي',
          'المجموعة 1',
          0.75,
          'بانتظار مراجعة الفصل الثالث',
          Colors.blue,
        ),
        _buildProjectCard(
          'تطبيق التمويل اللامركزي',
          'المجموعة 5',
          0.40,
          'قيد العمل على الفصل الثاني',
          Colors.orange,
        ),
        _buildProjectCard(
          'نظام إدارة المكتبات',
          'المجموعة 12',
          1.0,
          'تم الانتهاء من المشروع',
          Colors.green,
        ),
      ],
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
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(30)),
                child: Text(groupName, style: const TextStyle(color: Color(0xFF2D62ED), fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF94A3B8), size: 16),
            ],
          ),
          const SizedBox(height: 15),
          Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: AlwaysStoppedAnimation<Color>(progress == 1.0 ? Colors.green : const Color(0xFF2D62ED)),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              Text('${(progress * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: statusColor, size: 16),
              const SizedBox(width: 6),
              Text(status, style: TextStyle(color: statusColor, fontSize: 13, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }
}
