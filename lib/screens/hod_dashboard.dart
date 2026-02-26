import 'package:flutter/material.dart';

class HodDashboard extends StatelessWidget {
  const HodDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'لوحة تحكم رئيس القسم',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black),
            onPressed: () {},
          ),
          const CircleAvatar(
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=hod'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'مرحباً، د. خالد منصور',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'قسم علوم الحاسوب | العام الجامعي 2025-2026',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            
            // بطاقات الإحصائيات السريعة
            Row(
              children: [
                _buildStatCard('المجموعات', '42', Icons.groups, Colors.blue),
                const SizedBox(width: 12),
                _buildStatCard('المشرفين', '15', Icons.person, Colors.orange),
                const SizedBox(width: 12),
                _buildStatCard('الطلاب', '126', Icons.school, Colors.green),
              ],
            ),
            
            const SizedBox(height: 24),
            const Text(
              'طلبات الاعتماد المعلقة',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // قائمة طلبات الاعتماد
            _buildApprovalItem('اعتماد عنوان بحث', 'المجموعة 5 - نظام إدارة المستشفيات', 'منذ ساعتين'),
            _buildApprovalItem('اعتماد خطة بحث', 'المجموعة 12 - تطبيق التجارة الإلكترونية', 'منذ 5 ساعات'),
            
            const SizedBox(height: 24),
            const Text(
              'نظرة عامة على الإنجاز',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // بطاقة مراقبة الإنجاز
            _buildProgressOverviewCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApprovalItem(String type, String detail, String time) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.pending_actions, color: Colors.orange, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(type, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(detail, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(time, style: const TextStyle(color: Colors.grey, fontSize: 10)),
              TextButton(
                onPressed: () {},
                child: const Text('مراجعة', style: TextStyle(color: Color(0xFF2D62ED), fontSize: 12)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildProgressRow('المرحلة 1: تسجيل العنوان', 0.95),
          const SizedBox(height: 12),
          _buildProgressRow('المرحلة 2: خطة البحث', 0.80),
          const SizedBox(height: 12),
          _buildProgressRow('المرحلة 3: الإطار النظري', 0.45),
          const SizedBox(height: 12),
          _buildProgressRow('المرحلة 4: الدراسة الميدانية', 0.15),
        ],
      ),
    );
  }

  Widget _buildProgressRow(String label, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(
              progress > 0.8 ? Colors.green : (progress > 0.4 ? Colors.blue : Colors.orange),
            ),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
