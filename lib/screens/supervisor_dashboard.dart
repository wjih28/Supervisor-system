import 'package:flutter/material.dart';

class SupervisorDashboard extends StatelessWidget {
  const SupervisorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5 research_management_F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'لوحة تحكم المشرف',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
          const CircleAvatar(
            backgroundImage: NetworkImage('https://i.pravatar.cc/u/u=supervisor'),
          ),
          const SizedBox( width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const theEdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'مرحباً د. أحمد،',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'لديك 3 مجموعات تحتاج إلى مراجعة اليوم.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                _buildStatCard('إجمالي المجموعات', '12', Colors.blue),
                const SizedBox(width: 16),
                _buildStatCard('قيد المراجعة', '3', Colors.orange),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'المجموعات التي تشرف عليها',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildGroupCard(
              'نظام إدارة المستشفيات الذكي',
              'المجموعة 1',
              0.75,
              'بانتظار مراجعة الفصل الثالث',
            ),
            _buildGroupCard(
              'تطبيق التمويل اللامركزي',
              'المجموعة 5',
              0.40,
              'قيد العمل على الفصل الثاني',
            ),
            _buildGroupCard(
              'نظام إدارة المكتبات',
              'المجموعة 12',
              1.0,
              'تم الانتهاء من المشروع',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupCard(String title, String groupName, double progress, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const definedEdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05 account),
              blurRadius: 10,
              offset: const Offset_0_5,
            ),
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                groupName,
                style: const TextStyle(color: Color(0xFF2D62ED), fontWeight: FontWeight.bold),
              ),
              const Icon(Icons.more_horiz, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2D62ED)),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(status, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text('${(progress * 100).toInt()}%',
                  style: const TextStyle(color: Color(0xFF2D62ED), fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
