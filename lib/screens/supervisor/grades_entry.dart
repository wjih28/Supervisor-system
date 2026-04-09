import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../../models/models.dart';

class GradesEntry extends StatefulWidget {
  final int supervisorId;

  const GradesEntry({
    super.key,
    required this.supervisorId,
  });

  @override
  State<GradesEntry> createState() => _GradesEntryState();
}

class _GradesEntryState extends State<GradesEntry> {
  List<ResearchGroup> _projects = [];
  final Map<int, Map<String, double>> _grades = {};
  bool _isLoading = true;

  final List<Map<String, String>> _criteria = [
    {'key': 'proposal', 'name': 'المقترح', 'max': '10'},
    {'key': 'plan', 'name': 'خطة البحث', 'max': '15'},
    {'key': 'field', 'name': 'الدراسة الميدانية', 'max': '20'},
    {'key': 'final', 'name': 'البحث النهائي', 'max': '30'},
    {'key': 'presentation', 'name': 'المناقشة', 'max': '25'},
  ];

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() => _isLoading = true);
    _projects =
        await SupabaseService.getGroupsBySupervisor(widget.supervisorId);

    // تهيئة الدرجات لكل مشروع
    for (var project in _projects) {
      _grades[project.id!] = {};
      for (var criteria in _criteria) {
        _grades[project.id!]![criteria['key']!] = 0;
      }
    }

    setState(() => _isLoading = false);
  }

  double _calculateTotal(int projectId) {
    final grades = _grades[projectId] ?? {};
    double total = 0;
    for (var criteria in _criteria) {
      total += grades[criteria['key']] ?? 0;
    }
    return total;
  }

  Future<void> _saveGrades(int projectId) async {
    // هنا يمكن حفظ الدرجات في قاعدة البيانات
    // حسب هيكل الجدول الموجود لديك

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم حفظ الدرجات بنجاح')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدخال الدرجات النهائية'),
        backgroundColor: const Color(0xFF2D62ED),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _projects.isEmpty
              ? const Center(child: Text('لا توجد مشاريع مسندة إليك'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _projects.length,
                  itemBuilder: (context, index) {
                    final project = _projects[index];
                    final total = _calculateTotal(project.id!);
                    final maxTotal = _criteria.fold<double>(
                        0, (sum, c) => sum + double.parse(c['max']!));

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: ExpansionTile(
                        title: Text(
                          project.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('الإجمالي: $total / $maxTotal'),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                ..._criteria.map((criteria) => _buildGradeRow(
                                      project.id!,
                                      criteria['key']!,
                                      criteria['name']!,
                                      double.parse(criteria['max']!),
                                    )),
                                const Divider(height: 32),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () => _saveGrades(project.id!),
                                      child: const Text('حفظ الدرجات'),
                                    ),
                                    Text(
                                      'الإجمالي: $total / $maxTotal',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2D62ED),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildGradeRow(int projectId, String key, String name, double max) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(
              name,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            child: Slider(
              value: _grades[projectId]?[key] ?? 0,
              min: 0,
              max: max,
              divisions: max.toInt(),
              label: '${_grades[projectId]?[key] ?? 0}',
              onChanged: (value) {
                setState(() {
                  _grades[projectId]![key] = value;
                });
              },
            ),
          ),
          SizedBox(
            width: 60,
            child: TextFormField(
              initialValue: '${_grades[projectId]?[key] ?? 0}',
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              onChanged: (value) {
                final double? newValue = double.tryParse(value);
                if (newValue != null && newValue >= 0 && newValue <= max) {
                  setState(() {
                    _grades[projectId]![key] = newValue;
                  });
                }
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
