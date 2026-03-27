import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';
import '../services/supabase_service.dart';

class SupervisorDashboard extends StatefulWidget {
  final Supervisor? supervisor;
  const SupervisorDashboard({super.key, this.supervisor});

  @override
  State<SupervisorDashboard> createState() => _SupervisorDashboardState();
}

class _SupervisorDashboardState extends State<SupervisorDashboard> {
  final supabase = Supabase.instance.client;
  bool _isLoading = true;
  List<ResearchGroup> _groups = [];
  int _pendingReviews = 0;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (widget.supervisor == null) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);
    try {
      // جلب المجموعات الحقيقية من قاعدة البيانات
      final groups = await SupabaseService.getGroupsBySupervisor(widget.supervisor!.id!);
      
      setState(() {
        _groups = groups;
        _totalGroups = groups.length;
        // حالياً سنفترض أن المجموعات التي حالتها ليست "مكتملة" تحتاج مراجعة
        _pendingReviews = groups.where((g) => g.stateId != 3).length; 
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading dashboard: $e');
      setState(() => _isLoading = false);
    }
  }

  int _totalGroups = 0;

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
