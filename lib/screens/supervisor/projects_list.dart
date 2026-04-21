import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supervisor_system/models/research_group.dart';
import 'package:supervisor_system/services/supabase_service.dart';

class SupervisorProjectsList extends StatefulWidget {
  final bool isGuest;

  const SupervisorProjectsList({Key? key, this.isGuest = false}) : super(key: key);

  @override
  State<SupervisorProjectsList> createState() => _SupervisorProjectsListState();
}

class _SupervisorProjectsListState extends State<SupervisorProjectsList> {
  List<ResearchGroup> _projects = [];
  bool _isLoading = false;

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
          supervisorId: 1,
          description: 'نظام متكامل لإدارة العمليات الطبية',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ResearchGroup(
          id: 2,
          name: 'تطبيق التجارة الإلكترونية المتقدم',
          progress: 0.45,
          status: 'in_progress',
          supervisorId: 1,
          description: 'منصة بيع وشراء متطورة',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        ResearchGroup(
          id: 3,
          name: 'نظام تتبع الحافلات المدرسية',
          progress: 0.90,
          status: 'pending_approval',
          supervisorId: 1,
          description: 'تتبع مباشر لحافلات المدارس',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];
      setState(() => _isLoading = false);
    } else {
      try {
        final user = Supabase.instance.client.auth.currentUser;
        if (user == null) {
          setState(() => _isLoading = false);
          return;
        }
        final projects = await SupabaseService.getGroupsBySupervisor(user.id as int);
        setState(() {
          _projects = projects;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ في تحميل المشاريع: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Align(
          alignment: Alignment.centerRight,
          child: Text('قائمة المشاريع'),
        ),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _projects.isEmpty
              ? const Center(child: Text('لا توجد مشاريع لعرضها'))
              : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: _projects.length,
                  itemBuilder: (context, index) {
                    final project = _projects[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              project.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.right,
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              'الحالة: ${project.status}',
                              textAlign: TextAlign.right,
                            ),
                            const SizedBox(height: 4.0),
                            Text(
                              'التقدم: ${(project.progress! * 100).toStringAsFixed(0)}%',
                              textAlign: TextAlign.right,
                            ),
                            const SizedBox(height: 8.0),
                            LinearProgressIndicator(
                              value: project.progress,
                              backgroundColor: Colors.grey[300],
                              color: Colors.blueAccent,
                            ),
                            const SizedBox(height: 8.0),
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: TextButton(
                                onPressed: () {
                                  // Navigate to project details
                                  // Navigator.push(context, MaterialPageRoute(builder: (context) => ProjectDetailsScreen(projectId: project.id!)));
                                },
                                child: const Text('عرض التفاصيل'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
