import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  // تأكد من تهيئة Flutter قبل أي عمليات أخرى
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة Supabase مباشرة بالقيم المزودة
  try {
    await Supabase.initialize(
      url: "https://quakwoghhxoobcgcknsj.supabase.co",
      anonKey: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF1YWt3b2doaHhvb2JjZ2NrbnNqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjY0MjAyNTMsImV4cCI6MjA4MTk5NjI1M30.OYmQVRGhirs7cJDI64rRqQZss6RDnof8kABlZNQDHbA",
    );
    debugPrint('✅ تم تهيئة Supabase بنجاح');
  } catch (e) {
    debugPrint('❌ فشل تهيئة Supabase: $e');
  }

  runApp(const GraduationApp());
}

class GraduationApp extends StatelessWidget {
  const GraduationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'نظام إدارة مشاريع التخرج',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Arial',
        useMaterial3: true,
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const LoginScreen(),
    );
  }
}
