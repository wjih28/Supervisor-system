import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../../models/models.dart';
import 'project_details.dart';

class SupervisorProjectsList extends StatefulWidget {
  final int supervisorId;
  final String supervisorName;
  final bool isGuest;

  const SupervisorProjectsList({
    super.key,
    required this.supervisorId,
    required this.supervisorName,
    this.isGuest = false,
  });

  @override
  State<SupervisorProjectsList> createState() => _SupervisorProjectsListState();
}

class _SupervisorProjectsListState extends State<SupervisorProjectsList> {
  List<ResearchGroup> _projects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoading = true);
    if (widget.isGuest) {
      _projects = [
        ResearchGroup(
          id: 1,
          name: 'نظام إدارة المستشفيات الذكي',
          progress: 0.75,
          status: 'in_progress',
          programId: 1,
          supervisorId: 1,
        ),
        ResearchGroup(
          id: 2,
          name: 'تطبيق التجارة الإلكترونية المتقدم',
          progress: 0.45,
          status: 'in_progress',
          programId: 1,
          supervisorId: 1,
        ),
        ResearchGroup(
          id: 3,
          name: 'نظام تتبع الحافلات المدرسية',
          progress: 0.90,
          status: 'pending_approval',
          programId: 1,
          supervisorId: 1,
        ),
      ];
    } else {
      _projects = await SupabaseService.getGroupsBySupervisor(widget.supervisorId);
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المشاريع المشرف عليها'),
        backgroundColor: const Color(0xFF2D62ED),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _projects.isEmpty
              ? const Center(child: Text('لا توجد مشاريع حالياً'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _projects.length,
                  itemBuilder: (context, index) {
                    final project = _projects[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(project.name),
                        subtitle: Text(
                            'نسبة الإنجاز: ${((project.progress ?? 0) * 100).toInt()}%'),
                        trailing: Chip(
                          label: Text(_getStatusText(project.status)),
                          backgroundColor:
                              _getStatusColor(project.status).withOpacity(0.2),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProjectDetails(
                                projectId: project.id!,
                                supervisorId: widget.supervisorId,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'pending_approval':
        return 'قيد المراجعة';
      case 'approved':
        return 'معتمد';
      case 'completed':
        return 'مكتمل';
      default:
        return status ?? 'غير محدد';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'in_progress':
        return Colors.orange;
      case 'pending_approval':
        return Colors.purple;
      case 'approved':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
