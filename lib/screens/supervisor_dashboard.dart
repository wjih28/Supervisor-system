import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supervisor_system/screens/supervisor/projects_list.dart';
import 'package:supervisor_system/screens/supervisor/chats_screen.dart';
import 'package:supervisor_system/screens/supervisor/settings_screen.dart';

class SupervisorDashboard extends StatefulWidget {
  final bool isGuest;
  final String? supervisorName;
  final String? supervisorEmail;

  const SupervisorDashboard({
    Key? key,
    this.isGuest = false,
    this.supervisorName,
    this.supervisorEmail,
  }) : super(key: key);

  @override
  State<SupervisorDashboard> createState() => _SupervisorDashboardState();
}

class _SupervisorDashboardState extends State<SupervisorDashboard> {
  int _selectedIndex = 0;
  String _supervisorName = 'المشرف';

  @override
  void initState() {
    super.initState();
    if (widget.isGuest) {
      _supervisorName = 'ضيف';
    } else if (widget.supervisorName != null) {
      _supervisorName = widget.supervisorName!;
    } else {
      _loadSupervisorName();
    }
  }

  Future<void> _loadSupervisorName() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() {
        _supervisorName = user.userMetadata?['full_name'] ?? 'المشرف';
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      // Projects List Screen
      SupervisorProjectsList(isGuest: widget.isGuest),
      // Chat Screen
      const ChatScreen(),
      // Settings Screen
      const SettingsScreen(),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('مرحباً بك، $_supervisorName'),
          centerTitle: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.blueAccent),
              onPressed: _showNotificationsDialog,
            ),
          ],
        ),
        body: _widgetOptions.elementAt(_selectedIndex),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_open),
              label: 'المشاريع',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'المحادثات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'الإعدادات',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.blueAccent,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
