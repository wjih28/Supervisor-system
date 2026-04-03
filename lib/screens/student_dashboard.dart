import 'package:flutter/material.dart';
import '../models/models.dart';

class StudentDashboard extends StatelessWidget {
  final Student? student;
  const StudentDashboard({super.key, this.student});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'لوحة تحكم الطالب',
          style:
              TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeHeader(),
            const SizedBox(height: 25),
            _buildStatusCard(),
            const SizedBox(height: 30),
            const Text(
              'مراحل المشروع',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 15),
            _buildStagesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'مرحباً، ${student?.name ?? "الطالب"} 👋',
          style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 6),
        const Text(
          'تابع تقدمك في مشروع التخرج من هنا.',
          style: TextStyle(color: Color(0xFF64748B), fontSize: 15),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D62ED),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF2D62ED).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10)),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('حالة المشروع الحالية',
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
              Icon(Icons.auto_graph_rounded, color: Colors.white, size: 24),
            ],
          ),
          SizedBox(height: 15),
          Text(
            'قيد العمل على الفصل الثاني',
            style: TextStyle(
                color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: 0.4,
                  backgroundColor: Colors.white24,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 15),
              Text('40%',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStagesList() {
    final stages = [
      {'title': 'الفصل الأول: المقدمة', 'status': 'مكتمل', 'isDone': true},
      {
        'title': 'الفصل الثاني: الدراسات السابقة',
        'status': 'قيد المراجعة',
        'isDone': false
      },
      {'title': 'الفصل الثالث: المنهجية', 'status': 'لم يبدأ', 'isDone': false},
    ];

    return Column(
      children: stages
          .map((stage) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                ),
                child: Row(
                  children: [
                    Icon(
                      stage['isDone'] as bool
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color:
                          stage['isDone'] as bool ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        stage['title'] as String,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: stage['isDone'] as bool
                              ? Colors.black87
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                    Text(
                      stage['status'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: stage['isDone'] as bool
                            ? Colors.green
                            : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
