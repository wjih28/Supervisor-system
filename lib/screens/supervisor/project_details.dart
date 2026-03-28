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
  List<ProjectFeedback> _feedbacks = []; // Assuming ProjectFeedback model exists
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
      _students = await SupabaseService.getGroupStudents(_project!.id!); // Assuming getGroupStudents exists
      _feedbacks = await SupabaseService.getProjectFeedback(widget.projectId); // Assuming getProjectFeedback exists
    }

    setState(() => _isLoading = false);
  }

  Future<void> _updateStatus(String newStatus) async {
    final success =
        await SupabaseService.updateGroupStatus(widget.projectId, newStatus, _project?.progress ?? 0.0); // Changed to updateGroupStatus
    if (success && mounted) {
      setState(() {
        _project = _project?.copyWith(status: newStatus); // Use copyWith
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث حالة المشروع بنجاح')),
      );
    }
  }

  Future<void> _updateStage(String newStage) async {
    // Assuming SupabaseService.updateProjectStage exists and updates currentStage
    final success =
        await SupabaseService.updateProjectStage(widget.projectId, newStage); // Assuming this method exists
    if (success && mounted) {
      setState(() {
        _project = _project?.copyWith(currentStage: newStage); // Use copyWith
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
                value: 'edit_status',
                child: Text('تغيير حالة المشروع'),
              ),
              const PopupMenuItem(
                value: 'edit_stage',
                child: Text('تغيير المرحلة الحالية'),
              ),
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
                  // عنوان المشروع
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'عنوان البحث',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _project?.name ?? 'بدون عنوان',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'الوصف',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _project?.description ?? 'لا يوجد وصف',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // حالة المشروع والمرحلة
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

                  // نسبة الإنجاز
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'نسبة الإنجاز',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                '${((_project?.progress ?? 0) * 100).toInt()}%',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D62ED),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: LinearProgressIndicator(
                                    value: _project?.progress ?? 0,
                                    backgroundColor: Colors.grey.shade200,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                      Color(0xFF2D62ED),
                                    ),
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

                  // أعضاء الفريق
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'أعضاء الفريق',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
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
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  backgroundColor: student.role == 'leader'
                                      ? Colors.green.withOpacity(0.2)
                                      : Colors.orange.withOpacity(0.2),
                                ),
                              )),
                          if (_students.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Text('لا يوجد أعضاء مسجلين'),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // أزرار الإجراءات
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
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.folder_open),
                          label: const Text('الملفات'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: const Color(0xFF2D62ED),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
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
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.comment),
                          label: const Text('الملاحظات'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // قسم الملاحظات
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'الملاحظات والتقييمات',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_feedbacks.isEmpty)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16),
                                child: Text('لا توجد ملاحظات حتى الآن'),
                              ),
                            )
                          else
                            ..._feedbacks.map((feedback) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Card(
                                    color: Colors.grey[100],
                                    margin: EdgeInsets.zero,
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            feedback.comment,
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'بواسطة: ${feedback.supervisorName ?? 'مشرف غير معروف'}',
                                            style: const TextStyle(
                                                fontSize: 12, color: Colors.grey),
                                          ),
                                          Text(
                                            'تاريخ: ${feedback.createdAt != null ? '${feedback.createdAt!.day}/${feedback.createdAt!.month}/${feedback.createdAt!.year}' : 'غير معروف'}',
                                            style: const TextStyle(
                                                fontSize: 12, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 14, color: color),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'in_progress':
        return 'قيد التنفيذ';
      case 'completed':
        return 'مكتملة';
      case 'delayed':
        return 'متأخرة';
      default:
        return 'غير معروف';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'pending':
        return Colors.grey;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'delayed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStageText(String? stage) {
    return stage ?? 'غير محدد';
  }

  void _showStatusDialog() {
    String? selectedStatus = _project?.status;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تغيير حالة المشروع'),
          content: DropdownButtonFormField<String>(
            value: selectedStatus,
            items: const [
              DropdownMenuItem(value: 'pending', child: Text('قيد الانتظار')),
              DropdownMenuItem(value: 'in_progress', child: Text('قيد التنفيذ')),
              DropdownMenuItem(value: 'completed', child: Text('مكتملة')),
              DropdownMenuItem(value: 'delayed', child: Text('متأخرة')),
            ],
            onChanged: (value) {
              selectedStatus = value;
            },
            decoration: const InputDecoration(
              labelText: 'الحالة',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedStatus != null) {
                  _updateStatus(selectedStatus!);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('تحديث'),
            ),
          ],
        );
      },
    );
  }

  void _showStageDialog() {
    String? selectedStage = _project?.currentStage;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تغيير المرحلة الحالية'),
          content: DropdownButtonFormField<String>(
            value: selectedStage,
            items: const [
              DropdownMenuItem(value: 'proposal', child: Text('اقتراح')),
              DropdownMenuItem(value: 'design', child: Text('تصميم')),
              DropdownMenuItem(value: 'implementation', child: Text('تنفيذ')),
              DropdownMenuItem(value: 'testing', child: Text('اختبار')),
              DropdownMenuItem(value: 'deployment', child: Text('نشر')),
            ],
            onChanged: (value) {
              selectedStage = value;
            },
            decoration: const InputDecoration(
              labelText: 'المرحلة',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                if (selectedStage != null) {
                  _updateStage(selectedStage!);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('تحديث'),
            ),
          ],
        );
      },
    );
  }
}

// Extension to allow copying ResearchGroup with new values
extension ResearchGroupCopyWith on ResearchGroup {
  ResearchGroup copyWith({
    int? id,
    String? name,
    int? supervisorId,
    int? stateId,
    int? leaderId,
    String? description,
    double? progress,
    String? status,
    String? currentStage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ResearchGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      supervisorId: supervisorId ?? this.supervisorId,
      stateId: stateId ?? this.stateId,
      leaderId: leaderId ?? this.leaderId,
      description: description ?? this.description,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      currentStage: currentStage ?? this.currentStage,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Placeholder for ProjectFeedback model if it doesn't exist yet
// You should define this model in models.dart based on your Supabase schema
class ProjectFeedback {
  final int? id;
  final int? projectId;
  final int? supervisorId;
  final String comment;
  final String? supervisorName; // Assuming you want to display supervisor name
  final DateTime? createdAt;

  ProjectFeedback({
    this.id,
    this.projectId,
    this.supervisorId,
    required this.comment,
    this.supervisorName,
    this.createdAt,
  });

  factory ProjectFeedback.fromJson(Map<String, dynamic> json) {
    return ProjectFeedback(
      id: json['comment_id'], // Assuming it maps to comment_id in review_comments
      projectId: json['id_group'], // Assuming it maps to id_group in review_comments
      supervisorId: json['id_sprvsr'], // Assuming it maps to id_sprvsr in review_comments
      comment: json['comment_text'],
      supervisorName: json['supervisor_name'], // Adjust according to your Supabase join/view
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
    );
  }
}
