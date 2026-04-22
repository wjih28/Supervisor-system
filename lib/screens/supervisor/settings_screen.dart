import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supervisor_system/screens/auth/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _userName = 'اسم المشرف';
  String _userEmail = 'supervisor@example.com';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() {
        _userName = user.userMetadata?['full_name'] ?? 'اسم المشرف';
        _userEmail = user.email ?? 'supervisor@example.com';
      });
    }
  }

  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('الإشعارات', textAlign: TextAlign.right),
          content: const Text('لا توجد إشعارات جديدة حالياً.', textAlign: TextAlign.right),
          actions: <Widget>[
            TextButton(
              child: const Text('إغلاق'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showProfileBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.blueAccent,
                    child: Text(
                      _userName.isNotEmpty ? _userName[0].toUpperCase() : '؟',
                      style: const TextStyle(fontSize: 30, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Center(
                  child: Text(
                    _userName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Center(
                  child: Text(
                    _userEmail,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Supabase.instance.client.auth.signOut();
                      if (mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                          (Route<dynamic> route) => false,
                        );
                      }
                    },
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text('تسجيل الخروج', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الإعدادات'),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'نظام إدارة مشاريع التخرج',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2024 جميع الحقوق محفوظة',
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Text(
                        'تم تطوير هذا التطبيق كجزء من مشروع تخرج.',
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.blueAccent),
              onPressed: _showNotificationsDialog,
            ),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: _showProfileBottomSheet,
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildSettingsSection(
              context,
              'المعلومات الشخصية',
              Icons.person_outline,
              () => _showProfileBottomSheet(),
            ),
            _buildSettingsSection(
              context,
              'الإشعارات',
              Icons.notifications_none,
              _showNotificationsDialog,
            ),
            _buildSettingsSection(
              context,
              'الأمان والخصوصية',
              Icons.lock_outline,
              () {},
            ),
            _buildSettingsSection(
              context,
              'المساعدة والدعم',
              Icons.help_outline,
              () {},
            ),
            _buildSettingsSection(
              context,
              'حول التطبيق',
              Icons.info_outline,
              () {
                showAboutDialog(
                  context: context,
                  applicationName: 'نظام إدارة مشاريع التخرج',
                  applicationVersion: '1.0.0',
                  applicationLegalese: '© 2024 جميع الحقوق محفوظة',
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 15),
                      child: Text(
                        'تم تطوير هذا التطبيق كجزء من مشروع تخرج.',
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: Colors.blueAccent),
        title: Text(title, textAlign: TextAlign.right),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
