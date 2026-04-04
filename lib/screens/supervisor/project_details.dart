import 'package:flutter/material.dart';
import 'package:graduation_research_management/services/supabase_service.dart';
import 'package:graduation_research_management/models/models.dart';
import 'project_files.dart';
import 'add_feedback.dart';

class ProjectDetails extends StatefulWidget {
  final int projectId;
  final int supervisorId;

  const ProjectDetails({
    super.key,
    required this.projectId,
    required this.supervisorId,
  });

  @override
  State<ProjectDetails> createState() => _ProjectDetailsState();
}

class _ProjectDetailsState extends State<ProjectDetails> {
  ResearchGroup? _project;
  List<Student> _students = [];
  List<ProjectFeedback> _feedbacks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    _project = await SupabaseService.getProjectById(widget.projectId);
    if (_project != null) {
      _students = await SupabaseService.getGroupStudents(_project!.id ?? 0);
      _feedbacks = await SupabaseService.getProjectFeedback(widget.projectId);
    }

    setState(() => _isLoading = false);
  }

  Future<void> _updateStatus(String newStatus) async {
    final success = await SupabaseService.updateGroupStatus(
      widget.projectId,
      newStatus,
      _project?.progress ?? 0.0,
    );
    if (success && mounted) {
      setState(() {
        _project = _project?.copyWith(status: newStatus);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث حالة المشروع بنجاح')),
      );
    }
  }

  Future<void> _updateStage(String newStage) async {
    final success =
        await SupabaseService.updateProjectStage(widget.projectId, newStage);
    if (success && mounted) {
      setState(() {
        _project = _project?.copyWith(currentStage: newStage);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث مرحلة المشروع بنجاح')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المشروع'),
        backgroundColor: const Color(0xFF2D62ED),
        foregroundColor: Colors.white,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'edit_status') {
                _showStatusDialog();
              } else if (value == 'edit_stage') {
                _showStageDialog();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                  value: 'edit_status', child: Text('تغيير حالة المشروع')),
              const PopupMenuItem(
                  value: 'edit_stage', child: Text('تغيير المرحلة الحالية')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('عنوان البحث',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey)),
                          const SizedBox(height: 8),
                          Text(_project?.name ?? 'بدون عنوان',
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          const Text('الوصف',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey)),
                          const SizedBox(height: 8),
                          Text(_project?.description ?? 'لا يوجد وصف',
                              style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoCard(
                          title: 'حالة المشروع',
                          value: _getStatusText(_project?.status),
                          color: _getStatusColor(_project?.status),
                          icon: Icons.info_outline,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInfoCard(
                          title: 'المرحلة الحالية',
                          value: _getStageText(_project?.currentStage),
                          color: Colors.blue,
                          icon: Icons.timeline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('نسبة الإنجاز',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                  '${((_project?.progress ?? 0) * 100).toInt()}%',
                                  style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D62ED))),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: _project?.progress ?? 0,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                            Color(0xFF2D62ED)),
                                    minHeight: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text('أعضاء الفريق',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          if (_students.isEmpty)
                            const Center(
                                child: Padding(
                                    padding: EdgeInsets.all(16),
                                    child: Text('لا يوجد أعضاء مسجلين')))
                          else
                            ..._students.map((student) => ListTile(
                                  leading: const Icon(Icons.person,
                                      color: Color(0xFF2D62ED)),
                                  title: Text(student.name),
                                  subtitle: Text(student.email ?? ''),
                                  trailing: Chip(
                                    label: Text(
                                        student.role == 'leader'
                                            ? 'قائد الفريق'
                                            : 'عضو',
                                        style: const TextStyle(fontSize: 12)),
                                    backgroundColor: student.role == 'leader'
                                        ? Colors.green.withOpacity(0.2)
                                        : Colors.orange.withOpacity(0.2),
                                  ),
                                )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ProjectFiles(
                                        projectId: widget.projectId,
                                        supervisorId: widget.supervisorId,
                                        projectTitle: _project?.name ??
                                            ''))).then((_) => _loadData());
                          },
                          icon: const Icon(Icons.folder_open),
                          label: const Text('الملفات'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => AddFeedback(
                                        projectId: widget.projectId,
                                        supervisorId: widget.supervisorId,
                                        projectTitle: _project?.name ??
                                            ''))).then((_) => _loadData());
                          },
                          icon: const Icon(Icons.add_comment),
                          label: const Text('إضافة ملاحظة'),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2D62ED),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('الملاحظات والتعليقات',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  if (_feedbacks.isEmpty)
                    const Center(
                        child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Text('لا توجد ملاحظات حالياً')))
                  else
                    ..._feedbacks.map((feedback) => _buildFeedbackCard(feedback)),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard(
      {required String title,
      required String value,
      required Color color,
      required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          Text(value,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(ProjectFeedback feedback) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (feedback.isResolved == true)
                  const Icon(Icons.check_circle, color: Colors.green, size: 20)
                else
                  TextButton(
                    onPressed: () async {
                      if (feedback.id != null) {
                        await SupabaseService.resolveFeedback(feedback.id!);
                        _loadData();
                      }
                    },
                    child: const Text('تحديد كمحلول'),
                  ),
                Text(_getStageText(feedback.stage),
                    style: const TextStyle(
                        color: Color(0xFF2D62ED), fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text(feedback.comment, style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 12),
            Text(_formatDate(feedback.createdAt),
                style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
          ],
        ),
      ),
    );
  }

  void _showStatusDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تغيير حالة المشروع', textAlign: TextAlign.right),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('قيد العمل', textAlign: TextAlign.right),
              onTap: () {
                _updateStatus('in_progress');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('مكتمل', textAlign: TextAlign.right),
              onTap: () {
                _updateStatus('completed');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('متأخر', textAlign: TextAlign.right),
              onTap: () {
                _updateStatus('delayed');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showStageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تغيير المرحلة الحالية', textAlign: TextAlign.right),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('المقترح', textAlign: TextAlign.right),
              onTap: () {
                _updateStage('proposal');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('خطة البحث', textAlign: TextAlign.right),
              onTap: () {
                _updateStage('plan');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('الدراسة الميدانية', textAlign: TextAlign.right),
              onTap: () {
                _updateStage('field');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('البحث النهائي', textAlign: TextAlign.right),
              onTap: () {
                _updateStage('final');
                Navigator.pop(context);
              },
            ),
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
      default:
        return 'غير محدد';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'in_progress':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'delayed':
        return Colors.red;
      default:
        return Colors.grey;
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

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.year}/${date.month}/${date.day}';
  }
}
